require 'reform/form/dry'

module Session
  class SignIn < Trailblazer::Operation

    contract do
      feature Reform::Form::Dry
      undef :persisted?
      attr_reader :user
      
      property :email,    virtual: true
      property :password, virtual: true

      validation do

        configure do
          option :form
          config.messages_file = 'config/error_messages.yml'

          # change this in order to have variable (@user) in order to have it available in the contract and
          # run just @model = contract.user instead of another find_by
          def user 
            return User.find_by(email: form.email)
          end

          def user_exists?
            return user != nil
          end

          def password_ok? #change this in order to run this only if user exists
            Tyrant::Authenticatable.new(user).digest?(form.password) == true
          end
        end
        
        required(:email).filled(:user_exists?)
        required(:password).filled(:password_ok?)
      end
    end


    def process(params)
      validate(params) do
        @model = get_user(params)
      end
    end
  private
    def get_user(params)
      return User.find_by(email: params[:email])
    end
  end
end