{ pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    # Use KDL config file for full control over keybinds
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  # Full zellij config with Alt-based keybinds (no conflicts with neovim)
  xdg.configFile."zellij/config.kdl".text = ''
    // Clean, minimal UI
    pane_frames false
    simplified_ui true
    default_shell "fish"
    mouse_mode false
    copy_on_select true

    ui {
      pane_frames {
        hide_session_name true
        rounded_corners false
      }
    }

    // Alt-based keybinds - no conflicts with neovim Ctrl keys
    keybinds clear-defaults=true {
      normal {
        // Mode switching with Alt
        bind "Alt p" { SwitchToMode "Pane"; }
        bind "Alt t" { SwitchToMode "Tab"; }
        bind "Alt r" { SwitchToMode "Resize"; }
        bind "Alt m" { SwitchToMode "Move"; }
        bind "Alt s" { SwitchToMode "Scroll"; }
        bind "Alt o" { SwitchToMode "Session"; }

        // Quick pane navigation (no mode switch needed)
        bind "Alt h" { MoveFocus "Left"; }
        bind "Alt l" { MoveFocus "Right"; }
        bind "Alt j" { MoveFocus "Down"; }
        bind "Alt k" { MoveFocus "Up"; }

        // Quick tab navigation
        bind "Alt 1" { GoToTab 1; }
        bind "Alt 2" { GoToTab 2; }
        bind "Alt 3" { GoToTab 3; }
        bind "Alt 4" { GoToTab 4; }
        bind "Alt 5" { GoToTab 5; }
        bind "Alt [" { GoToPreviousTab; }
        bind "Alt ]" { GoToNextTab; }

        // Quick splits
        bind "Alt -" { NewPane "Down"; }
        bind "Alt \\" { NewPane "Right"; }

        // Floating pane toggle
        bind "Alt f" { ToggleFloatingPanes; }
        bind "Alt w" { TogglePaneEmbedOrFloating; }

        // Fullscreen toggle
        bind "Alt z" { ToggleFocusFullscreen; }
      }

      pane {
        bind "Esc" { SwitchToMode "Normal"; }
        bind "h" { MoveFocus "Left"; }
        bind "l" { MoveFocus "Right"; }
        bind "j" { MoveFocus "Down"; }
        bind "k" { MoveFocus "Up"; }
        bind "n" { NewPane; SwitchToMode "Normal"; }
        bind "-" { NewPane "Down"; SwitchToMode "Normal"; }
        bind "\\" { NewPane "Right"; SwitchToMode "Normal"; }
        bind "x" { CloseFocus; SwitchToMode "Normal"; }
        bind "f" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
        bind "z" { TogglePaneFrames; SwitchToMode "Normal"; }
        bind "w" { ToggleFloatingPanes; SwitchToMode "Normal"; }
        bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
        bind "r" { SwitchToMode "RenamePane"; PaneNameInput 0; }
      }

      tab {
        bind "Esc" { SwitchToMode "Normal"; }
        bind "h" { GoToPreviousTab; }
        bind "l" { GoToNextTab; }
        bind "n" { NewTab; SwitchToMode "Normal"; }
        bind "x" { CloseTab; SwitchToMode "Normal"; }
        bind "s" { ToggleActiveSyncTab; SwitchToMode "Normal"; }
        bind "1" { GoToTab 1; SwitchToMode "Normal"; }
        bind "2" { GoToTab 2; SwitchToMode "Normal"; }
        bind "3" { GoToTab 3; SwitchToMode "Normal"; }
        bind "4" { GoToTab 4; SwitchToMode "Normal"; }
        bind "5" { GoToTab 5; SwitchToMode "Normal"; }
        bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
      }

      resize {
        bind "Esc" { SwitchToMode "Normal"; }
        bind "h" { Resize "Increase Left"; }
        bind "l" { Resize "Increase Right"; }
        bind "j" { Resize "Increase Down"; }
        bind "k" { Resize "Increase Up"; }
        bind "H" { Resize "Decrease Left"; }
        bind "L" { Resize "Decrease Right"; }
        bind "J" { Resize "Decrease Down"; }
        bind "K" { Resize "Decrease Up"; }
        bind "=" { Resize "Increase"; }
        bind "-" { Resize "Decrease"; }
      }

      move {
        bind "Esc" { SwitchToMode "Normal"; }
        bind "h" { MovePane "Left"; }
        bind "l" { MovePane "Right"; }
        bind "j" { MovePane "Down"; }
        bind "k" { MovePane "Up"; }
        bind "n" { MovePane; }
        bind "Tab" { MovePane; }
      }

      scroll {
        bind "Esc" { SwitchToMode "Normal"; }
        bind "e" { EditScrollback; SwitchToMode "Normal"; }
        bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
        bind "j" { ScrollDown; }
        bind "k" { ScrollUp; }
        bind "d" { HalfPageScrollDown; }
        bind "u" { HalfPageScrollUp; }
        bind "f" { PageScrollDown; }
        bind "b" { PageScrollUp; }
      }

      search {
        bind "Esc" { SwitchToMode "Normal"; }
        bind "j" { ScrollDown; }
        bind "k" { ScrollUp; }
        bind "n" { Search "down"; }
        bind "N" { Search "up"; }
        bind "c" { SearchToggleOption "CaseSensitivity"; }
        bind "w" { SearchToggleOption "Wrap"; }
        bind "o" { SearchToggleOption "WholeWord"; }
      }

      entersearch {
        bind "Esc" { SwitchToMode "Scroll"; }
        bind "Enter" { SwitchToMode "Search"; }
      }

      session {
        bind "Esc" { SwitchToMode "Normal"; }
        bind "d" { Detach; }
        bind "q" { Quit; }
      }

      renametab {
        bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
        bind "Enter" { SwitchToMode "Normal"; }
      }

      renamepane {
        bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
        bind "Enter" { SwitchToMode "Normal"; }
      }
    }
  '';
}
