# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the user here. For example:
    #
    #   return unless user.present?
    #   can :read, :all
    #   return unless user.admin?
    #   can :manage, :all
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
  
    # user ||= User.new(role: 'user')  # Guest user (not logged in)
    
    # if user.admin?
    #   can :manage, :all  # Admins can manage everything
    # else
    #   can :read, Product  # Regular users can only read products
    #   can :create, Order  # Allow users to place orders
    #   # can :manage, Order, user_id: user.id  # Users can manage their own orders
    # end
    user ||= User.new # Guest user

    if user.admin?
      can :manage, Product # Admins can create, edit, and delete products
    else
      can :read, Product  # Regular users can only view products
    end

  end
end
