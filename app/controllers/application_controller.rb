class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_cart
  before_action :initialize_cart
  

  # rescue_from CanCan::AccessDenied do |exception|
  #   redirect_to root_path, alert: "Access Denied!"
  # end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: "You are not authorized to perform this action."
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def current_cart
    session[:cart] ||= {}
  end

  def authorize_admin
    redirect_to root_path, alert: "Access Denied!" unless current_user&.admin?
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :address, :role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email])
  end

  def initialize_cart
    session[:cart] ||= {}
  end
  


end
