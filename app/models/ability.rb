class Ability
  include CanCan::Ability

  def initialize(user)
    case user.role
    when User::ROLE_CLIENT
      can :show, User, id: user.id
      can :read, Contract, buyer_id: user.id, active: true
    when User::ROLE_MANAGER
      can :manage, Contract, seller_id: user.id
      can :manage, MoneyTransfer, receiver_id: user.id

      can :show, User do |target_user|
        target_user == user || user.clients.include?(target_user)
      end
      can :index, User
      can :update, User, id: user.id
    when User::ROLE_SUPER_MANAGER
      can :manage, :all
    when User::ROLE_ADMIN
      can :manage, :all
    end
  end
end
