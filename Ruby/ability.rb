#coding: utf-8
class Ability
  include CanCan::Ability

  def initialize(user, mall=nil, product=nil)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all
    else

############ All ##############    

      can [:read], User do |do_user|
        user.has_role?(:admin, mall) && do_user.has_role?(:user, mall)
      end
      can [:read, :update], User do |do_user|
        do_user.id == user.id || ( do_user.mall_id == mall.id && user.has_role?(:admin, mall) )
      end
      can [:add_admin], User do |do_user|
        user.id == mall.owner_id && do_user.mall_id == mall.id
      end      
      can [:remove_admin], User do |do_user|
        user.id == mall.owner_id && do_user.mall_id == mall.id
      end

############ aidou_users ##############         

      can [:create], Org do |org|
        user.has_role?(:org_user)
      end
      can [:read,:update], Org do |org|
        user.has_role?(:admin, org)
      end
      can [:index], Mall do |mall|
        user.has_role?(:admin, mall.org)
      end
      can [:show], Mall
      can [:create], Mall do |mall|
        user.has_role?(:org_user) 
      end
      can [:update], Mall do |mall|
        user.has_role?(:admin, mall)
      end

############ mall_admins && mall_users ##############         

      can [:read], Teacher do |teacher|
        mall.can_serve?(false, "Teacher", :read)
      end
      can [:create, :created], Teacher do |teacher|
        user.has_role?(:admin, mall) && mall.can_serve?(false, "Teacher", :create)
      end
      can [:update, :destroy], Teacher do |teacher|
        (user.has_role?(:admin, mall) || ( user.has_role?(:mall_teacher, mall) && teacher.user_id == user.id)) && mall.can_serve?(false, "Teacher", :update)
      end      
#-------------------------------------------------------        
      can [:read], Product do |product|
        mall.can_serve?(false, "Product", :read)
      end
      can [:grouped], Product do |product|
        mall.can_serve?(false, "Product", :read) && product.accepts_user?(user)
      end
      can [:create, :update, :destroy, :enable, :disable, :update_grouping, :edit_grouping], Product do |product|
        user.has_role?(:admin, mall) && mall.can_serve?(false, "Product", :create)
      end
#-------------------------------------------------------      
      can [:index], Episode do |episode|
        user.has_role?(:admin, mall) && mall.can_serve?(false, "Episode", :read)
      end
      can [:show], Episode do |episode|
        (user.has_role?(:admin, mall) || user.can_read_item?(episode, product)) && mall.can_serve?(true, "Episode", :show)
      end
      can [:create, :update], Episode do |episode|
        user.has_role?(:admin, mall) && mall.can_serve?(true, "Episode", :create, true)
      end
      can [:destroy], Episode do |episode|
        user.has_role?(:admin, mall) && mall.can_serve?(false, "Episode", :destroy)
      end      

      can [:index], Live do |live|
        user.has_role?(:admin, mall) && mall.can_serve?(false, "Live", :read)
      end
      can [:show], Live do |live|
        (user.has_role?(:admin, mall) || user.can_read_item?(live, product)) && mall.can_serve?(true, "Live", :show)
      end
      can [:create, :update], Live do |live|
        user.has_role?(:admin, mall) && mall.can_serve?(true, "Live", :create)
      end
      can [:destroy], Live do |live|
        user.has_role?(:admin, mall) && mall.can_serve?(false, "Live", :destroy)
      end              

      can [:index], FaceToFace do |f2f|
        user.has_role?(:admin, mall) && mall.can_serve?(false, "Episode", :read)
      end
      can [:show], FaceToFace do |f2f|
        user.has_role?(:admin, mall) && mall.can_serve?(true, "Episode", :show)
      end
      can [:create, :update, :destroy], FaceToFace do |f2f|
        user.has_role?(:admin, mall) && mall.can_serve?(true, "Episode", :update)
      end
#-------------------------------------------------------        
      can [:read], Order do |order|
        ((user.has_role?(:admin, mall) && order.mall_id == mall.id) || (order.user_id == user.id)) && mall.can_serve?(false, "Order", :read)
      end
      can [:check], Order do |order|
        user.has_role?(:admin, mall) && can_serve?(false, "Order", :read)
      end
      can [:waiting, :checkout, :paid], Order do |order|
        order.user_id == user.id && mall.can_serve?(false, "Order", :checkout)
      end
      can [:create], Order do |order|
        user.id != nil && mall.can_serve?(false, "Order", :create)
      end
      can [:update, :destroy, :clear_waiting], Order do |order|
        (order.user_id == user.id) && order.status == Order::STATUS["未付款"] && mall.can_serve?(false, "Order", :destroy)
      end
#-------------------------------------------------------        
      can [:read], Transaction do |t|
        (user.has_role?(:admin, mall) && t.mall_id == mall.id) || (t.user_id == user.id)
      end
      can [:update, :destroy], Transaction do |t|
        (t.user_id == user.id) && t.status == Order::STATUS["未付款"]
      end      
#-------------------------------------------------------        
      can [:create], Paper do |paper|
        user.has_role?(:admin, mall) && mall.can_serve?(false, "Paper", :create)
      end
      can [:manage], Paper do |paper|
        user.has_role?(:admin, mall) && paper.mall_id == mall.id && mall.can_serve?(false, "Paper", :manage)
      end      
      can [:read], Paper do |paper|
        user.has_role?(:user, paper.mall) && mall.can_serve?(false, "Paper", :read)
      end
#-------------------------------------------------------        
      can [:create], Question do |question|
        user.has_role?(:admin, mall) && mall.can_serve?(false, "Question", :create)
      end
      can [:manage], Question do |question|
        user.has_role?(:admin, mall) && question.mall_id == mall.id && mall.can_serve?(false, "Question", :manage)
      end      
#-------------------------------------------------------        
      can [:create], Answer do |answer|
        ( user.has_role?(:admin, mall) || user.has_role?(:user, mall) ) && mall.can_serve?(false, "Answer", :create)
      end
      can [:read, :incorrect_answers], Answer do |answer|
        answer.user_id == user.id && mall.can_serve?(false, "Answer", :read)
      end
#-------------------------------------------------------       
      can [:read], WatchingRecord do |rec|
        user.has_role?(:admin, rec.mall) || user.id == rec.user_id 
      end
#-------------------------------------------------------       
      can [:create], Category do |cat|
        user.has_role?(:admin, mall)
      end
      can [:manage], Category do |cat|
        user.has_role?(:admin, mall) && cat.mall_id == mall.id 
      end          
      can [:read] ,Category do |cat|
        user.has_role?(:admin, mall) 
      end
#-------------------------------------------------------  
      can [:manage, :close], Comment do |comment|
        user.has_role?(:admin, mall) && mall.can_serve?(false, "Comment", :manage)
      end
      can [:create], Comment do |comment|      
        product.accepts_user?(user, comment.commentable) && mall.can_serve?(false, "Comment", :create)  
      end

      can [:manage], Like do |l|
        user.has_role?(:admin, mall) && mall.can_serve?(false, "Comment", :manage) 
      end      
      can [:create], Like do |l|      
        mall.can_serve?(false, "Comment", :create)  
      end
#-------------------------------------------------------       
      can [:index], Payment do |p|
        user.has_role?(:admin, mall) || (user.has_role?(:mall_teacher, mall) && p.user_id == user.id)
      end
#-------------------------------------------------------     
      can [:read], Face do |face|
        (user.has_role?(:admin, mall) || user.id = face.user_id) && mall.can_serve?(false, "Face", :read)
      end
      can [:create], Face do |face|
        (user.has_role?(:admin, mall) || user.has_role?(:user, mall)) && mall.can_serve?(false, "Face", :create)
      end
      can [:destroy], Face do |face|
        (user.has_role?(:admin, mall) || user.id = face.user_id) && mall.can_serve?(false, "Face", :destroy)
      end      
#-------------------------------------------------------
      can [:manage], Group do |group|
        user.has_role?(:admin, mall) && mall.can_serve?(false, "Mall", :show)
      end 
#-------------------------------------------------------
      can [:create], UserQuestion do |quest|
        if product
          user.can_read_item?(quest.questionable, product) && mall.can_serve?(false, "Problem", :create)
        else
          mall.can_serve?(false, "Problem", :create)
        end
      end    
      can [:index, :update, :destroy], UserQuestion do |quest|
        (user.has_role?(:admin, mall) || user.id == quest.user_id) && mall.can_serve?(false, "Problem", :create)
      end

      can [:create], UserAnswer do |answer|
        mall.can_serve?(false, "Problem", :create)
      end    
      can [:index, :update, :destroy], UserAnswer do |answer|
        (user.has_role?(:admin, mall) || user.id == answer.user_id) && mall.can_serve?(false, "Problem", :create)
      end

    end
  end
end