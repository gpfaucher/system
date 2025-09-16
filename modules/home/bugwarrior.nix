{ pkgs, ... }:
{
  home.packages = [ pkgs.python312Packages.bugwarrior pkgs.taskwarrior3 ];

  xdg.configFile."bugwarrior/bugwarriorrc" = {
    text = ''
      [general]
      targets = linear

      [linear]
      service = linear
      # Project/company name (case-sensitive) as it appears in Linear URL
      # Example: https://linear.app/<org>
      organization = YOUR_LINEAR_ORG
      # Read token from environment for safety
      api_key = $BUGWARRIOR_LINEAR_API_TOKEN
      # Map to Taskwarrior fields
      default.priority = M
      description_template = {{ title }} [{{ identifier }}]
      tags = linear
      # Optional: query filters
      # team = ENG
      # status = In Progress
    '';
  };

  systemd.user.services.bugwarrior-pull = {
    Unit.Description = "Bugwarrior pull from Linear into Taskwarrior";
    Service = {
      Type = "oneshot";
      Environment = [
        # Ensure Taskwarrior uses XDG config
        "TASKRC=%h/.config/task/taskrc"
      ];
      ExecStart = "${pkgs.python312Packages.bugwarrior}/bin/bugwarrior-pull";
    };
  };

  systemd.user.timers.bugwarrior-pull = {
    Unit.Description = "Schedule bugwarrior pulls";
    Timer = {
      OnCalendar = "hourly";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}

