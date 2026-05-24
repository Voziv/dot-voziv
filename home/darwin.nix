{ username, ... }:
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
}
