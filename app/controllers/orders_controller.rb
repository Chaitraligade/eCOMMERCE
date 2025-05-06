class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :thank_you]
  # before_action :initialize_cart, only: [:add_to_cart, :remove_from_cart, :show_cart]
  # before_action :authenticate_admin!, only: [:mark_paid]
  # before_save :calculate_total_price
  before_action :initialize_cart, only: [:add_to_cart, :remove_from_cart, :show_cart]
  def index
    @orders = current_user.orders.order(created_at: :desc)
  end
  
  def new
    @order = Order.new
    respond_to do |format|
      format.html  # ✅ Ensure HTML is allowed
      format.json { render json: @order }
    end
  end
  # ✅ Show Cart Items
   # ✅ Show Cart Page
   def show_cart
    # @cart_items = session[:cart] || [] 
    @cart_items = session[:cart].map do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next unless product
      { product: product, quantity: quantity }
    end.compact
  end
 
  def cart
    @cart = session[:cart] || {} # Ensure @cart is initialized
  
    @cart_items = @cart.map do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next if product.nil? # Skip nil products to prevent errors
  
      { product: product, quantity: quantity, price: product.price || 0 }
    end.compact # Remove nil values
  
    @total_price = @cart_items.sum { |item| item[:quantity] * item[:price].to_f }
  end
  
  
  # ✅ Add Product to Cart
  def add_to_cart
    product_id = params[:product_id].to_s
    session[:cart] ||= {}  # Initialize cart if empty
    session[:cart][product_id] = (session[:cart][product_id] || 0) + 1
    
    redirect_to cart_orders_orders_path, notice: "Product added to cart!"
  end
  
  def remove_from_cart
    session[:cart] ||= {}
  
    if session[:cart][params[:product_id].to_s]
      session[:cart].delete(params[:product_id].to_s)
      flash[:notice] = "Product removed from cart."
    else
      flash[:alert] = "Product not found in cart."
    end
  
    redirect_to cart_orders_orders_path
  end
  
  def create
    if session[:cart].blank?
      flash[:alert] = "Your cart is empty!"
      redirect_to root_path
      return
    end
  
    Rails.logger.debug "🔍 Session Cart: #{session[:cart].inspect}"
  
    order = current_user.orders.build(order_params)
  
    # Define products to exclude
    # excluded_products = ["Toy Car"]
  
    valid_products = session[:cart].select do |product_id, _quantity|
      product = Product.find_by(id: product_id)
      # product && !excluded_products.include?(product.name)
    end
  
    Rails.logger.debug "✅ Valid Products: #{valid_products.inspect}"
  
    if valid_products.empty?
      flash[:alert] = "No valid products to create an order."
      redirect_to root_path
      return
    end
  
    order.total_price = valid_products.sum do |product_id, quantity|
      product = Product.find_by(id: product_id)
      price = product ? product.price.to_f : 0
      qty = quantity.to_i  # Ensure it's an integer
      Rails.logger.debug "💰 Calculating: Product ID #{product_id}, Price #{price}, Qty #{qty}, Total #{price * qty}"
      price * qty
    end
    # order.total_price = order.order_items.sum { |item| item.product.price.to_f * item.quantity }
    Rails.logger.debug "💰 Calculated Total Price: #{order.total_price}"
  
    if order.save
      session[:cart] = {}  # Clear cart
      redirect_to thank_you_order_path(order)
    else
      Rails.logger.debug "❌ Order creation failed: #{order.errors.full_messages.join(', ')}"
      redirect_to root_path, alert: "Order could not be created."
    end
  end
  

  def checkout
    @order = Order.new # Ensure an empty order object is available
  end  
  
  def show
    @order = Order.find_by(id: params[:id])
  
    if @order.nil? || @order.user != current_user
      redirect_to orders_path, alert: "Order not found."
      return
    end
  
    respond_to do |format|
      format.html
      format.json { render json: @order }
    end
  end
  

  private

  def save_order_items(order)
    session[:cart].each do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next unless product

      order.order_items.create!(
        product_id: product.id,
        quantity: quantity,
        price: product.price
      )
    end
  end

  def initialize_cart
    session[:cart] ||= {}
  end

  def order_params
    params.require(:order).permit(:user_name, :user_address, :payment_method, :total_price, :status, :paid)
  end

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end

  def set_order
    @order = current_user.orders.find_by(id: params[:id])
  end
end
