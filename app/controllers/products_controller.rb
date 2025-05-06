class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]
  load_and_authorize_resource except: :destroy
  before_action :set_categories, only: [:new, :edit]
  
  before_action :authenticate_user!, except: [:index, :show]
  before_action :authorize_admin, only: [:new, :create, :edit, :update, :destroy]

  def index
    @categories = Category.all  
    @products = Product.all

    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end

    if params[:search].present?
      @products = @products.search_by_name_and_description(params[:search])
    end

    @products = @products.page(params[:page]).per(2)
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    @product.user = current_user  # ✅ Assign user explicitly
    if @product.save
      redirect_to @product, notice: "Product created successfully!"
    else
      puts @product.errors.full_messages  # Debugging
      render :new, status: :unprocessable_entity
    end
  end
  

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: "Product was successfully updated."
    else
      flash[:alert] = @product.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product = Product.find_by(id: params[:id])

    if @product.nil?
      redirect_to products_path, alert: "Product not found!" and return
    end

    unless current_user&.admin?
      redirect_to root_path, alert: "You are not authorized to perform this action." and return
    end

    @product.destroy
    redirect_to products_url, notice: "Product was successfully deleted."
  end

  private

  def set_product
    @product = Product.find(params[:id])  # ✅ Correct
  end
  

  def set_categories
    @categories = Category.all
  end    

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :image, :category_id, :user_id)
  end

  def authorize_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access Denied!"
    end
  end
end
