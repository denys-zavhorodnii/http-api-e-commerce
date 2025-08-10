import sqlite3 from 'sqlite3';
import { promisify } from 'util';

// Types for our E-commerce database
export interface User {
  id: number;
  username: string;
  email: string;
  first_name: string;
  last_name: string;
  phone?: string;
  address?: string;
  city?: string;
  state?: string;
  zip_code?: string;
  country: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Supplier {
  id: number;
  name: string;
  contact_person?: string;
  email?: string;
  phone?: string;
  address?: string;
  city?: string;
  state?: string;
  zip_code?: string;
  country: string;
  is_active: boolean;
  created_at: string;
}

export interface Brand {
  id: number;
  name: string;
  description?: string;
  logo_url?: string;
  website?: string;
  is_active: boolean;
  created_at: string;
}

export interface Category {
  id: number;
  name: string;
  description?: string;
  parent_id?: number;
  image_url?: string;
  is_active: boolean;
  created_at: string;
}

export interface Product {
  id: number;
  name: string;
  description?: string;
  sku: string;
  price: number;
  sale_price?: number;
  cost_price?: number;
  brand_id?: number;
  supplier_id?: number;
  stock_quantity: number;
  min_stock_level: number;
  weight?: number;
  dimensions?: string;
  is_active: boolean;
  is_featured: boolean;
  rating_average: number;
  rating_count: number;
  created_at: string;
  updated_at: string;
}

export interface ProductWithRelations extends Product {
  brand?: Brand;
  supplier?: Supplier;
  categories: Category[];
  images: ProductImage[];
}

export interface ProductImage {
  id: number;
  product_id: number;
  image_url: string;
  alt_text?: string;
  is_primary: boolean;
  sort_order: number;
  created_at: string;
}

export interface Review {
  id: number;
  product_id: number;
  user_id: number;
  rating: number;
  title?: string;
  comment?: string;
  is_verified_purchase: boolean;
  is_approved: boolean;
  created_at: string;
}

export interface ReviewWithUser extends Review {
  user: User;
}

export interface Order {
  id: number;
  order_number: string;
  user_id: number;
  status: string;
  subtotal: number;
  tax_amount: number;
  shipping_amount: number;
  total_amount: number;
  shipping_address?: string;
  shipping_city?: string;
  shipping_state?: string;
  shipping_zip_code?: string;
  shipping_country?: string;
  notes?: string;
  created_at: string;
  updated_at: string;
}

export interface OrderWithItems extends Order {
  user: User;
  items: OrderItem[];
}

export interface OrderItem {
  id: number;
  order_id: number;
  product_id: number;
  product_name: string;
  product_sku: string;
  quantity: number;
  unit_price: number;
  total_price: number;
  created_at: string;
}

export interface PaginationOptions {
  page: number;
  limit: number;
  offset: number;
}

export interface PaginatedResult<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
}

export interface ProductFilters {
  category_id?: number;
  brand_id?: number;
  min_price?: number;
  max_price?: number;
  in_stock?: boolean;
  is_featured?: boolean;
  search?: string;
  sort_by?: 'name' | 'price' | 'rating' | 'created_at';
  sort_order?: 'asc' | 'desc';
}

class Database {
  private db: sqlite3.Database;

  constructor() {
    this.db = new sqlite3.Database('./database/ecommerce.db');
  }

  async initialize(): Promise<void> {
    const sql = await this.readFile('./database/init.sql');
    return new Promise((resolve, reject) => {
      this.db.exec(sql, (err) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  }

  private async readFile(path: string): Promise<string> {
    const fs = require('fs');
    return fs.promises.readFile(path, 'utf8');
  }

  // User methods
  async getAllUsers(options: PaginationOptions = { page: 1, limit: 10, offset: 0 }): Promise<PaginatedResult<User>> {
    const countQuery = 'SELECT COUNT(*) as total FROM users WHERE is_active = 1';
    const dataQuery = 'SELECT * FROM users WHERE is_active = 1 ORDER BY created_at DESC LIMIT ? OFFSET ?';
    
    const total = await this.getCount(countQuery);
    const users = await this.getAll<User>(dataQuery, [options.limit, options.offset]);
    
    return this.createPaginatedResult(users, total, options);
  }

  async getUserById(id: number): Promise<User | null> {
    const users = await this.getAll<User>('SELECT * FROM users WHERE id = ? AND is_active = 1', [id]);
    return users.length > 0 ? users[0] : null;
  }

  async getUserByEmail(email: string): Promise<User | null> {
    const users = await this.getAll<User>('SELECT * FROM users WHERE email = ? AND is_active = 1', [email]);
    return users.length > 0 ? users[0] : null;
  }

  // Product methods
  async getAllProducts(options: PaginationOptions = { page: 1, limit: 10, offset: 0 }): Promise<PaginatedResult<Product>> {
    const countQuery = 'SELECT COUNT(*) as total FROM products WHERE is_active = 1';
    const dataQuery = 'SELECT * FROM products WHERE is_active = 1 ORDER BY created_at DESC LIMIT ? OFFSET ?';
    
    const total = await this.getCount(countQuery);
    const products = await this.getAll<Product>(dataQuery, [options.limit, options.offset]);
    
    return this.createPaginatedResult(products, total, options);
  }

  async getProductById(id: number): Promise<Product | null> {
    const products = await this.getAll<Product>('SELECT * FROM products WHERE id = ? AND is_active = 1', [id]);
    return products.length > 0 ? products[0] : null;
  }

  async getProductBySku(sku: string): Promise<Product | null> {
    const products = await this.getAll<Product>('SELECT * FROM products WHERE sku = ? AND is_active = 1', [sku]);
    return products.length > 0 ? products[0] : null;
  }

  async getProductWithRelations(id: number): Promise<ProductWithRelations | null> {
    const product = await this.getProductById(id);
    if (!product) return null;

    const [brand, supplier, categories, images] = await Promise.all([
      product.brand_id ? this.getBrandById(product.brand_id) : null,
      product.supplier_id ? this.getSupplierById(product.supplier_id) : null,
      this.getProductCategories(id),
      this.getProductImages(id)
    ]);

    return {
      ...product,
      brand: brand || undefined,
      supplier: supplier || undefined,
      categories,
      images
    };
  }

  async searchProducts(filters: ProductFilters, options: PaginationOptions = { page: 1, limit: 10, offset: 0 }): Promise<PaginatedResult<Product>> {
    let whereClause = 'WHERE p.is_active = 1';
    const params: any[] = [];

    if (filters.category_id) {
      whereClause += ' AND EXISTS (SELECT 1 FROM product_categories pc WHERE pc.product_id = p.id AND pc.category_id = ?)';
      params.push(filters.category_id);
    }

    if (filters.brand_id) {
      whereClause += ' AND p.brand_id = ?';
      params.push(filters.brand_id);
    }

    if (filters.min_price !== undefined) {
      whereClause += ' AND p.price >= ?';
      params.push(filters.min_price);
    }

    if (filters.max_price !== undefined) {
      whereClause += ' AND p.price <= ?';
      params.push(filters.max_price);
    }

    if (filters.in_stock) {
      whereClause += ' AND p.stock_quantity > 0';
    }

    if (filters.is_featured) {
      whereClause += ' AND p.is_featured = 1';
    }

    if (filters.search) {
      whereClause += ' AND (p.name LIKE ? OR p.description LIKE ?)';
      const searchTerm = `%${filters.search}%`;
      params.push(searchTerm, searchTerm);
    }

    const orderBy = filters.sort_by || 'created_at';
    const orderDirection = filters.sort_order || 'desc';
    const orderClause = `ORDER BY p.${orderBy} ${orderDirection.toUpperCase()}`;

    const countQuery = `SELECT COUNT(*) as total FROM products p ${whereClause}`;
    const dataQuery = `SELECT p.* FROM products p ${whereClause} ${orderClause} LIMIT ? OFFSET ?`;

    const total = await this.getCount(countQuery, params);
    const products = await this.getAll<Product>(dataQuery, [...params, options.limit, options.offset]);

    return this.createPaginatedResult(products, total, options);
  }

  async getFeaturedProducts(limit: number = 10): Promise<Product[]> {
    return this.getAll<Product>('SELECT * FROM products WHERE is_featured = 1 AND is_active = 1 ORDER BY rating_average DESC LIMIT ?', [limit]);
  }

  async getProductsByCategory(categoryId: number, options: PaginationOptions = { page: 1, limit: 10, offset: 0 }): Promise<PaginatedResult<Product>> {
    const countQuery = `
      SELECT COUNT(*) as total 
      FROM products p 
      JOIN product_categories pc ON p.id = pc.product_id 
      WHERE pc.category_id = ? AND p.is_active = 1
    `;
    
    const dataQuery = `
      SELECT p.* 
      FROM products p 
      JOIN product_categories pc ON p.id = pc.product_id 
      WHERE pc.category_id = ? AND p.is_active = 1 
      ORDER BY p.created_at DESC 
      LIMIT ? OFFSET ?
    `;
    
    const total = await this.getCount(countQuery, [categoryId]);
    const products = await this.getAll<Product>(dataQuery, [categoryId, options.limit, options.offset]);
    
    return this.createPaginatedResult(products, total, options);
  }

  // Category methods
  async getAllCategories(): Promise<Category[]> {
    return this.getAll<Category>('SELECT * FROM categories WHERE is_active = 1 ORDER BY name');
  }

  async getCategoryById(id: number): Promise<Category | null> {
    const categories = await this.getAll<Category>('SELECT * FROM categories WHERE id = ? AND is_active = 1', [id]);
    return categories.length > 0 ? categories[0] : null;
  }

  async getCategoryWithChildren(id: number): Promise<Category & { children: Category[] } | null> {
    const category = await this.getCategoryById(id);
    if (!category) return null;

    const children = await this.getAll<Category>('SELECT * FROM categories WHERE parent_id = ? AND is_active = 1 ORDER BY name', [id]);
    
    return {
      ...category,
      children
    };
  }

  // Brand methods
  async getAllBrands(): Promise<Brand[]> {
    return this.getAll<Brand>('SELECT * FROM brands WHERE is_active = 1 ORDER BY name');
  }

  async getBrandById(id: number): Promise<Brand | null> {
    const brands = await this.getAll<Brand>('SELECT * FROM brands WHERE id = ? AND is_active = 1', [id]);
    return brands.length > 0 ? brands[0] : null;
  }

  // Supplier methods
  async getAllSuppliers(): Promise<Supplier[]> {
    return this.getAll<Supplier>('SELECT * FROM suppliers WHERE is_active = 1 ORDER BY name');
  }

  async getSupplierById(id: number): Promise<Supplier | null> {
    const suppliers = await this.getAll<Supplier>('SELECT * FROM suppliers WHERE id = ? AND is_active = 1', [id]);
    return suppliers.length > 0 ? suppliers[0] : null;
  }

  // Review methods
  async getProductReviews(productId: number, options: PaginationOptions = { page: 1, limit: 10, offset: 0 }): Promise<PaginatedResult<ReviewWithUser>> {
    const countQuery = 'SELECT COUNT(*) as total FROM reviews WHERE product_id = ? AND is_approved = 1';
    const dataQuery = `
      SELECT r.*, u.username, u.first_name, u.last_name 
      FROM reviews r 
      JOIN users u ON r.user_id = u.id 
      WHERE r.product_id = ? AND r.is_approved = 1 
      ORDER BY r.created_at DESC 
      LIMIT ? OFFSET ?
    `;
    
    const total = await this.getCount(countQuery, [productId]);
    const reviews = await this.getAll<ReviewWithUser>(dataQuery, [productId, options.limit, options.offset]);
    
    return this.createPaginatedResult(reviews, total, options);
  }

  async getProductAverageRating(productId: number): Promise<number> {
    const result = await this.getFirst<{ rating_average: number }>('SELECT rating_average FROM products WHERE id = ?', [productId]);
    return result ? result.rating_average : 0;
  }

  // Order methods
  async getUserOrders(userId: number, options: PaginationOptions = { page: 1, limit: 10, offset: 0 }): Promise<PaginatedResult<Order>> {
    const countQuery = 'SELECT COUNT(*) as total FROM orders WHERE user_id = ?';
    const dataQuery = 'SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?';
    
    const total = await this.getCount(countQuery, [userId]);
    const orders = await this.getAll<Order>(dataQuery, [userId, options.limit, options.offset]);
    
    return this.createPaginatedResult(orders, total, options);
  }

  async getOrderById(id: number): Promise<OrderWithItems | null> {
    const order = await this.getFirst<Order>('SELECT * FROM orders WHERE id = ?', [id]);
    if (!order) return null;

    const [user, items] = await Promise.all([
      this.getUserById(order.user_id),
      this.getAll<OrderItem>('SELECT * FROM order_items WHERE order_id = ?', [id])
    ]);

    return {
      ...order,
      user: user!,
      items
    };
  }

  // Helper methods
  private async getProductCategories(productId: number): Promise<Category[]> {
    return this.getAll<Category>(`
      SELECT c.* 
      FROM categories c 
      JOIN product_categories pc ON c.id = pc.category_id 
      WHERE pc.product_id = ? AND c.is_active = 1 
      ORDER BY pc.sort_order, c.name
    `, [productId]);
  }

  private async getProductImages(productId: number): Promise<ProductImage[]> {
    return this.getAll<ProductImage>(`
      SELECT * FROM product_images 
      WHERE product_id = ? 
      ORDER BY is_primary DESC, sort_order, id
    `, [productId]);
  }

  private async getCount(query: string, params: any[] = []): Promise<number> {
    const result = await this.getFirst<{ total: number }>(query, params);
    return result ? result.total : 0;
  }

  private createPaginatedResult<T>(data: T[], total: number, options: PaginationOptions): PaginatedResult<T> {
    const totalPages = Math.ceil(total / options.limit);
    return {
      data,
      pagination: {
        page: options.page,
        limit: options.limit,
        total,
        totalPages,
        hasNext: options.page < totalPages,
        hasPrev: options.page > 1
      }
    };
  }

  private async getAll<T>(query: string, params: any[] = []): Promise<T[]> {
    return new Promise((resolve, reject) => {
      this.db.all(query, params, (err, rows) => {
        if (err) {
          reject(err);
        } else {
          resolve(rows as T[]);
        }
      });
    });
  }

  private async getFirst<T>(query: string, params: any[] = []): Promise<T | null> {
    return new Promise((resolve, reject) => {
      this.db.get(query, params, (err, row) => {
        if (err) {
          reject(err);
        } else {
          resolve(row as T || null);
        }
      });
    });
  }

  async close(): Promise<void> {
    return new Promise((resolve) => {
      this.db.close(() => resolve());
    });
  }
}

export const db = new Database();
