import Fastify, { FastifyInstance } from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import { db, ProductFilters, PaginationOptions } from './database';

const server: FastifyInstance = Fastify({
  logger: true,
  trustProxy: true,
});

// Register plugins
server.register(cors, {
  origin: true,
  credentials: true,
});

server.register(helmet, {
  contentSecurityPolicy: false,
});

// Health check route
server.get('/health', async (request, reply) => {
  return { status: 'ok', timestamp: new Date().toISOString() };
});

// Database health check
server.get('/health/db', async (request, reply) => {
  try {
    const products = await db.getAllProducts({ page: 1, limit: 1, offset: 0 });
    return { 
      status: 'ok', 
      database: 'connected',
      products_count: products.pagination.total,
      timestamp: new Date().toISOString() 
    };
  } catch (error) {
    reply.status(500);
    return { 
      status: 'error', 
      database: 'disconnected',
      error: error instanceof Error ? error.message : 'Unknown error',
      timestamp: new Date().toISOString() 
    };
  }
});

// ===== PRODUCT ROUTES =====

// Get all products with pagination
server.get('/api/products', async (request, reply) => {
  try {
    const { page = 1, limit = 10 } = request.query as { page?: number; limit?: number };
    const offset = (page - 1) * limit;
    
    const products = await db.getAllProducts({ page, limit, offset });
    return products;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch products', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get product by ID
server.get('/api/products/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const productId = parseInt(id);
    
    if (isNaN(productId)) {
      reply.status(400);
      return { error: 'Invalid product ID' };
    }

    const product = await db.getProductById(productId);
    if (!product) {
      reply.status(404);
      return { error: 'Product not found' };
    }

    return product;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch product', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get product with all relations (brand, supplier, categories, images)
server.get('/api/products/:id/full', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const productId = parseInt(id);
    
    if (isNaN(productId)) {
      reply.status(400);
      return { error: 'Invalid product ID' };
    }

    const product = await db.getProductWithRelations(productId);
    if (!product) {
      reply.status(404);
      return { error: 'Product not found' };
    }

    return product;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch product with relations', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Search and filter products
server.get('/api/products/search', async (request, reply) => {
  try {
    const { 
      page = '1', 
      limit = '10', 
      category_id, 
      brand_id, 
      min_price, 
      max_price, 
      in_stock, 
      is_featured, 
      search, 
      sort_by, 
      sort_order 
    } = request.query as any;
    
    const pageNum = parseInt(page) || 1;
    const limitNum = parseInt(limit) || 10;
    const offset = (pageNum - 1) * limitNum;
    
    const filters: ProductFilters = {
      category_id: category_id ? parseInt(String(category_id)) : undefined,
      brand_id: brand_id ? parseInt(String(brand_id)) : undefined,
      min_price: min_price ? parseFloat(String(min_price)) : undefined,
      max_price: max_price ? parseFloat(String(max_price)) : undefined,
      in_stock: in_stock === 'true',
      is_featured: is_featured === 'true',
      search: search as string,
      sort_by: sort_by as any,
      sort_order: sort_order as any
    };

    const products = await db.searchProducts(filters, { page: pageNum, limit: limitNum, offset });
    return products;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to search products', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get featured products
server.get('/api/products/featured', async (request, reply) => {
  try {
    const { limit = 10 } = request.query as { limit?: number };
    const products = await db.getFeaturedProducts(limit);
    return { products, count: products.length };
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch featured products', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get products by category
server.get('/api/categories/:id/products', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const { page = 1, limit = 10 } = request.query as { page?: number; limit?: number };
    
    const categoryId = parseInt(id);
    if (isNaN(categoryId)) {
      reply.status(400);
      return { error: 'Invalid category ID' };
    }

    const offset = (page - 1) * limit;
    const products = await db.getProductsByCategory(categoryId, { page, limit, offset });
    return products;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch products by category', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// ===== CATEGORY ROUTES =====

// Get all categories
server.get('/api/categories', async (request, reply) => {
  try {
    const categories = await db.getAllCategories();
    return { categories, count: categories.length };
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch categories', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get category by ID
server.get('/api/categories/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const categoryId = parseInt(id);
    
    if (isNaN(categoryId)) {
      reply.status(400);
      return { error: 'Invalid category ID' };
    }

    const category = await db.getCategoryById(categoryId);
    if (!category) {
      reply.status(404);
      return { error: 'Category not found' };
    }

    return category;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch category', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get category with children
server.get('/api/categories/:id/children', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const categoryId = parseInt(id);
    
    if (isNaN(categoryId)) {
      reply.status(400);
      return { error: 'Invalid category ID' };
    }

    const category = await db.getCategoryWithChildren(categoryId);
    if (!category) {
      reply.status(404);
      return { error: 'Category not found' };
    }

    return category;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch category with children', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// ===== BRAND ROUTES =====

// Get all brands
server.get('/api/brands', async (request, reply) => {
  try {
    const brands = await db.getAllBrands();
    return { brands, count: brands.length };
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch brands', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get brand by ID
server.get('/api/brands/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const brandId = parseInt(id);
    
    if (isNaN(brandId)) {
      reply.status(400);
      return { error: 'Invalid brand ID' };
    }

    const brand = await db.getBrandById(brandId);
    if (!brand) {
      reply.status(404);
      return { error: 'Brand not found' };
    }

    return brand;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch brand', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// ===== SUPPLIER ROUTES =====

// Get all suppliers
server.get('/api/suppliers', async (request, reply) => {
  try {
    const suppliers = await db.getAllSuppliers();
    return { suppliers, count: suppliers.length };
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch suppliers', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get supplier by ID
server.get('/api/suppliers/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const supplierId = parseInt(id);
    
    if (isNaN(supplierId)) {
      reply.status(400);
      return { error: 'Invalid supplier ID' };
    }

    const supplier = await db.getSupplierById(supplierId);
    if (!supplier) {
      reply.status(404);
      return { error: 'Supplier not found' };
    }

    return supplier;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch supplier', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// ===== USER ROUTES =====

// Get all users with pagination
server.get('/api/users', async (request, reply) => {
  try {
    const { page = 1, limit = 10 } = request.query as { page?: number; limit?: number };
    const offset = (page - 1) * limit;
    
    const users = await db.getAllUsers({ page, limit, offset });
    return users;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch users', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get user by ID
server.get('/api/users/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const userId = parseInt(id);
    
    if (isNaN(userId)) {
      reply.status(400);
      return { error: 'Invalid user ID' };
    }

    const user = await db.getUserById(userId);
    if (!user) {
      reply.status(404);
      return { error: 'User not found' };
    }

    return user;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch user', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// ===== REVIEW ROUTES =====

// Get product reviews with pagination
server.get('/api/products/:id/reviews', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const { page = 1, limit = 10 } = request.query as { page?: number; limit?: number };
    
    const productId = parseInt(id);
    if (isNaN(productId)) {
      reply.status(400);
      return { error: 'Invalid product ID' };
    }

    const offset = (page - 1) * limit;
    const reviews = await db.getProductReviews(productId, { page, limit, offset });
    return reviews;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch product reviews', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// ===== ORDER ROUTES =====

// Get user orders with pagination
server.get('/api/users/:id/orders', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const { page = 1, limit = 10 } = request.query as { page?: number; limit?: number };
    
    const userId = parseInt(id);
    if (isNaN(userId)) {
      reply.status(400);
      return { error: 'Invalid user ID' };
    }

    const offset = (page - 1) * limit;
    const orders = await db.getUserOrders(userId, { page, limit, offset });
    return orders;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch user orders', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get order by ID with items
server.get('/api/orders/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const orderId = parseInt(id);
    
    if (isNaN(orderId)) {
      reply.status(400);
      return { error: 'Invalid order ID' };
    }

    const order = await db.getOrderById(orderId);
    if (!order) {
      reply.status(404);
      return { error: 'Order not found' };
    }

    return order;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch order', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// ===== UTILITY ROUTES =====

// Example API route
server.get('/api/hello', async (request, reply) => {
  return { message: 'Hello from E-commerce API!', timestamp: new Date().toISOString() };
});

// Example POST route
server.post('/api/echo', async (request, reply) => {
  return { 
    message: 'Echo response', 
    data: request.body,
    timestamp: new Date().toISOString() 
  };
});

// Start server
const start = async () => {
  try {
    // Initialize database
    await db.initialize();
    
    const port = process.env.PORT || 3000;
    const host = process.env.HOST || '0.0.0.0';
    
    await server.listen({ port: Number(port), host });
    
    console.log(`🚀 E-commerce API Server is running on http://${host}:${port}`);
    console.log(`📊 Health check: http://${host}:${port}/health`);
    console.log(`🗄️  Database health: http://${host}:${port}/health/db`);
    console.log(`🛍️  Products: http://${host}:${port}/api/products`);
    console.log(`📂 Categories: http://${host}:${port}/api/categories`);
    console.log(`🏷️  Brands: http://${host}:${port}/api/brands`);
    console.log(`👥 Users: http://${host}:${port}/api/users`);
    console.log(`📝 Reviews: http://${host}:${port}/api/products/1/reviews`);
    console.log(`📦 Orders: http://${host}:${port}/api/users/1/orders`);
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
};

start();
