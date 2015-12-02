class User_ProfileController < ApplicationController
    
    def new
        @user_profile = User_Profile.new
    end
    
    def create
        @user_profile = User_Profile.new(user_profile_params)
    
        if @user_profile.save
            redirect_to @user_profile
        else 
            render 'new'
        end
    end    
    
    def show
        @user_profile = User_Profile.find(params[:id])
    end

private
    def user_profile_params
        params.require(:user_profile).permit(:first_name, :last_name, :street_address, :unit_id, :phone, :email, :team_id, :password)
    end
