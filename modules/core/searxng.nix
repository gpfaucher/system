{pkgs, ...}: {
  services.searx = {
    enable = true;
    package = pkgs.searxng;
    settings = {
      server = {
        bind_address = "127.0.0.1";
        port = 8080;
        base_url = "http://localhost:8080/";
        secret_key = "bd4e0c4a2f3b4a598a7c9d0e1f2a3b4c";
      };
      search = {
        formats = ["html" "json"];
      };
      engines = [
        {name = "duckduckgo"; engine = "duckduckgo"; disabled = false;}
        {name = "google"; engine = "google"; disabled = false;}
        {name = "bing"; engine = "bing"; disabled = false;}
        {name = "wikipedia"; engine = "wikipedia"; disabled = false;}
        {name = "github"; engine = "github"; disabled = false;}
        {name = "stackoverflow"; engine = "stackoverflow"; disabled = false;}
      ];
    };
  };
}
