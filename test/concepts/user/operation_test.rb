require 'test_helper.rb'

class UserOperationTest < MiniTest::Spec

  it "validate correct input" do
    op = User::Create.(email: "test@email.com", password: "password", confirm_password: "password")
    op.model.persisted?.must_equal true
    op.model.email.must_equal "test@email.com"
  end

  it "wrong input" do
    res, op = User::Create.run(user: {})
    res.must_equal false
    op.errors.to_s.must_equal "{:email=>[\"is missing\", \"is in invalid format\"], :password=>[\"is missing\"], :confirm_password=>[\"is missing\", \"Passwords are not matching\"]}"
  end

  it "passwords not matching" do
    res,op = User::Create.run(email: "test@email.com", password: "password", confirm_password: "notpassword")
    res.must_equal false
    op.errors.to_s.must_equal "{:confirm_password=>[\"Passwords are not matching\"]}"
  end

  it "modify user" do
    op = User::Create.(email: "test@email.com", password: "password", confirm_password: "password")
    op.model.email.must_equal "test@email.com"

    op = User::Update.(id: op.model.id, email: "newtest@email.com")
    op.model.persisted?.must_equal true
    op.model.email.must_equal "newtest@email.com"
  end

  it "delete user" do
    op = User::Create.(email: "test@email.com", password: "password", confirm_password: "password")
    op.model.persisted?.must_equal true

    op = User::Delete.(id: op.model.id)
    op.model.persisted?.must_equal false
  end

  it "reset password" do 
    op = User::Create.(email: "test@email.com", password: "password", confirm_password: "password")
    op.model.persisted?.must_equal true

    User::ResetPassword.(email: op.model.email)

    model = User.find_by(email: op.model.email)

    assert Tyrant::Authenticatable.new(model).digest != "password"
    assert Tyrant::Authenticatable.new(model).digest == "NewPassword"
    Tyrant::Authenticatable.new(model).confirmed?.must_equal true
    Tyrant::Authenticatable.new(model).confirmable?.must_equal false

    Mail::TestMailer.deliveries.length.must_equal 1
    Mail::TestMailer.deliveries.first.to.must_equal ["test@email.com"]
    Mail::TestMailer.deliveries.first.body.raw_source.must_equal "Hi there, here is your temporary password: NewPassword. We suggest you to modify this password ASAP. Cheers" 
  end

  it "can't change password" do 
    user = User::Create.(email: "test@email.com", password: "password", confirm_password: "password").model
    user.persisted?.must_equal true

    res, op = User::ChangePassword.run(id: user.id, password: "new_password", new_password: "new_password", confirm_new_password: "wrong_password")
    res.must_equal false

    op.errors.to_s.must_equal "{:password=>[\"Wrong Password\"], :new_password=>[\"New password can't match the old one\"], :confirm_new_password=>[\"New Password are not matching\"]}"
  end

  it "change password" do 
    user = User::Create.(email: "test@email.com", password: "password", confirm_password: "password").model
    user.persisted?.must_equal true

    op = User::ChangePassword.(id: user.id, password: "password", new_password: "new_password", confirm_new_password: "new_password")
    op.model.persisted?.must_equal true

    user = User.find_by(email: user.email)

    assert Tyrant::Authenticatable.new(user).digest != "password"
    assert Tyrant::Authenticatable.new(user).digest == "new_password"
    Tyrant::Authenticatable.new(user).confirmed?.must_equal true
    Tyrant::Authenticatable.new(user).confirmable?.must_equal false    
  end

end