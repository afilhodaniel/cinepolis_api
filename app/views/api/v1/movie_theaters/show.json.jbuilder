json.user do
  json.id       @user.id
  json.avatar   @user.avatar.url(:avatar)
  json.name     @user.name
  json.bio      @user.bio
  json.username @user.username
  json.email    @user.email
end