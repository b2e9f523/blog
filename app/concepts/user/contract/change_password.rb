require 'reform/form/dry'

module User::Contract 
  class ChangePassword < Reform::Form 
    feature Reform::Form::Dry

    property :password, virtual: true
    property :new_password, virtual: true
    property :confirm_new_password, virtual: true

    validation do
      configure do
        option :form
        config.messages_file = 'config/error_messages.yml'

        def new_must_match?
          return form.new_password == form.confirm_new_password
        end

        def new_password_must_be_new?
          return form.password != form.new_password
        end

        def password_ok? #change this in order to run this only if user exists
          return Tyrant::Authenticatable.new(form.model).digest?(form.password) == true
        end

      end

      required(:password).filled
      required(:new_password).filled(:new_password_must_be_new?)
      required(:confirm_new_password).filled(:new_must_match?)

      validate(password_ok?: :password) do
        password_ok?
      end
    end
  end
end