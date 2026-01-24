{ config, ... }:
{
  age.secrets.tabby-token = {
    file = ./tabby-token.age;
    owner = "gabriel";
    group = "users";
    mode = "0400";
  };
}
