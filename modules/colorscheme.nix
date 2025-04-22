{ config, lib, ... }:

let
  mkColorschemeOpt =
    type:
    lib.mkOption {
      type = (
        lib.types.nullOr (
          lib.types.submodule {
            options.name = lib.mkOption {
              type = lib.types.enum (builtins.attrNames config.colorscheme.theme);
            };
            options.style = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.enum config.colorscheme.theme.${config.colorscheme.${type}.name}.styles
              );
            };
          }
        )
      );
      default = null;
    };

in
{
  options.colorscheme = {
    theme = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule ({
          options.styles = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
        })
      );
      default = { };
    };

    current = mkColorschemeOpt "current";
    currentLight = mkColorschemeOpt "currentLight";
    currentDark = mkColorschemeOpt "currentDark";
  };

  config = {
    colorscheme = {
      theme.catpuccin.styles = [
        "frappe"
        "latte"
        "machiatto"
        "mocha"
      ];
      theme.tokyonight.styles = [
        "day"
        "moon"
        "night"
        "storm"
      ];

      current = {
        name = "catpuccin";
        style = "mocha";
      };
      # currentLight = {
      #   name = "catpuccin";
      #   style = "mocha";
      # };
      # currentDark = {
      #   name = "tokyonight";
      #   style = "moon";
      # };
    };

    assertions =
      let
        hasCurrent = config.colorscheme.current != null;
        hasLight = config.colorscheme.currentLight != null;
        hasDark = config.colorscheme.currentDark != null;
      in
      [
        {
          assertion = (hasCurrent && !(hasLight || hasDark)) || (!hasCurrent && hasLight && hasDark);
          message = ''
            You must specify either:
              - `colorscheme.current`
            OR
              - both `colorscheme.currentLight` and `colorscheme.currentDark`
            but not both.
          '';
        }
      ];
  };

}

# Sure! Let's dive into the **optional bonus** features you mentioned:
#
# 1. **Auto-filling `light` and `dark` from `current`**.
# 2. **Treating `colorscheme.current` as a shortcut** for both `light` and `dark`.
#
# These are cool ways to streamline the configuration for users, and they can make the experience more intuitive. Essentially, if the user sets a `colorscheme.current`, the system will **automatically fill in** `light` and `dark` with some default values derived from `current`.
#
# ---
#
# ### 1. **Auto-filling `light` and `dark` from `current`**
#
# If the user specifies a `colorscheme.current` (let’s say `catpuccin`), the system could automatically choose reasonable defaults for `light` and `dark` from that same colorscheme.
#
# The idea here is to allow the user to only specify a `current` value, and if that’s provided, automatically fill out the corresponding `light` and `dark` values based on predefined defaults.
#
# For example:
# - If `colorscheme.current` is `catpuccin`, you could automatically fill in:
#   - `colorscheme.light` to `"catpuccin"` with a default style like `"latte"`.
#   - `colorscheme.dark` to `"catpuccin"` with a different default style, say `"mocha"`.
#
# ### Implementation
#
# We can make use of Nix's **`lib.mkIf`** to perform this auto-filling behavior. If `current` is set, we can infer the values for `light` and `dark` automatically.
#
# Here’s how we could implement it:
#
# ```nix
# { config, lib, ... }:
#
# let
#   mkColorschemeOpt = side: {
#     name = lib.mkOption {
#       type = lib.types.enum (builtins.attrNames config.colorschemes);
#     };
#     style = lib.mkOption {
#       type = lib.types.nullOr (
#         lib.types.enum config.colorschemes.${config.colorscheme.${side}.name}.styles
#       );
#     };
#   };
#
#   getDefaultStyle = colorscheme: let
#     styles = config.colorschemes.${colorscheme}.styles;
#   in if styles != [] then builtins.head styles else null;
#
# in
# {
#   options = {
#     colorschemes = lib.mkOption {
#       type = lib.types.attrsOf (
#         lib.types.submodule ({
#           options.styles = lib.mkOption {
#             type = lib.types.listOf lib.types.str;
#             default = [ ];
#           };
#         })
#       );
#       default = { };
#     };
#
#     colorscheme = {
#       current = lib.mkOption {
#         type = lib.types.nullOr lib.types.str;
#       };
#       light = mkColorschemeOpt "light";
#       dark = mkColorschemeOpt "dark";
#     };
#   };
#
#   config = {
#     colorschemes = {
#       catpuccin.styles = [
#         "frappe"
#         "latte"
#         "machiatto"
#         "mocha"
#       ];
#
#       tokyonight.styles = [
#         "day"
#         "moon"
#         "night"
#         "storm"
#       ];
#     };
#
#     # If `current` is specified, auto-fill `light` and `dark`
#     colorscheme.current = "catpuccin";  # For testing
#
#     # Auto-fill `light` and `dark` based on `current`
#     colorscheme.light = lib.mkIf (config.colorscheme ? current) {
#       name = config.colorscheme.current;
#       style = getDefaultStyle config.colorscheme.current;
#     };
#
#     colorscheme.dark = lib.mkIf (config.colorscheme ? current) {
#       name = config.colorscheme.current;
#       style = getDefaultStyle config.colorscheme.current;  # Possibly different style for dark
#     };
#   };
# }
# ```
#
# ### Explanation of Auto-filling:
#
# 1. **`getDefaultStyle` function**: This function fetches the styles for a given colorscheme and returns the first style (or `null` if no styles are defined).
# 2. **`lib.mkIf`**: If `colorscheme.current` is set, it fills in both `light` and `dark` with the same `name` (i.e., `current`), and it also picks the default `style` from the styles defined for that colorscheme.
# 3. **Default style selection**: If the colorscheme has defined styles (e.g., `latte`, `mocha`), it will automatically pick the first one. You could adjust this logic to use different default styles for `light` and `dark` if needed.
#
# #### Example Configuration:
#
# ```nix
# config = {
#   colorscheme.current = "catpuccin";  # Only specifying current
# };
# ```
#
# - This will **automatically fill**:
#   - `colorscheme.light` to `"catpuccin"`, style `"latte"`.
#   - `colorscheme.dark` to `"catpuccin"`, style `"mocha"` (or whatever the default dark style is).
#
# ---
#
# ### 2. **Treating `colorscheme.current` as a Shortcut**
#
# If `colorscheme.current` is specified, you can treat it as a "shortcut" where it automatically implies the user is using the same `colorscheme` for both `light` and `dark`. This means:
# - **If `colorscheme.current` is set**, we can automatically set both `colorscheme.light` and `colorscheme.dark` to that same `current` colorscheme, with default styles.
# - The user would only need to specify `current` and the system will handle `light` and `dark` automatically.
#
# ### How to Implement the Shortcut
#
# Here's how you could make `current` a shortcut:
#
# ```nix
# { config, lib, ... }:
#
# let
#   mkColorschemeOpt = side: {
#     name = lib.mkOption {
#       type = lib.types.enum (builtins.attrNames config.colorschemes);
#     };
#     style = lib.mkOption {
#       type = lib.types.nullOr (
#         lib.types.enum config.colorschemes.${config.colorscheme.${side}.name}.styles
#       );
#     };
#   };
#
#   getDefaultStyle = colorscheme: let
#     styles = config.colorschemes.${colorscheme}.styles;
#   in if styles != [] then builtins.head styles else null;
#
# in
# {
#   options = {
#     colorschemes = lib.mkOption {
#       type = lib.types.attrsOf (
#         lib.types.submodule ({
#           options.styles = lib.mkOption {
#             type = lib.types.listOf lib.types.str;
#             default = [ ];
#           };
#         })
#       );
#       default = { };
#     };
#
#     colorscheme = {
#       current = lib.mkOption {
#         type = lib.types.nullOr lib.types.str;
#       };
#       light = mkColorschemeOpt "light";
#       dark = mkColorschemeOpt "dark";
#     };
#   };
#
#   config = {
#     colorschemes = {
#       catpuccin.styles = [
#         "frappe"
#         "latte"
#         "machiatto"
#         "mocha"
#       ];
#
#       tokyonight.styles = [
#         "day"
#         "moon"
#         "night"
#         "storm"
#       ];
#     };
#
#     # User specifies `current`
#     colorscheme.current = "catpuccin";  # Only specifying current
#
#     # If `current` is specified, auto-fill `light` and `dark` with the same colorscheme
#     colorscheme.light = lib.mkIf (config.colorscheme ? current) {
#       name = config.colorscheme.current;
#       style = getDefaultStyle config.colorscheme.current;
#     };
#
#     colorscheme.dark = lib.mkIf (config.colorscheme ? current) {
#       name = config.colorscheme.current;
#       style = getDefaultStyle config.colorscheme.current;  # Can use a different style if needed
#     };
#   };
# }
# ```
#
# ### Explanation of Shortcut:
#
# - **If `current` is specified**, it automatically fills both `light` and `dark` with the same colorscheme and default styles.
# - **No need for `light` or `dark` to be specified**: The user only needs to specify `current` and the module will do the rest.
#
# #### Example Configuration:
#
# ```nix
# config = {
#   colorscheme.current = "catpuccin";  # Only specifying current
# };
# ```
#
# - This will **automatically fill**:
#   - `colorscheme.light` to `"catpuccin"`, style `"latte"`.
#   - `colorscheme.dark` to `"catpuccin"`, style `"mocha"` (or whatever the default style is).
#
# ---
#
# ### Combining Both Ideas (Auto-filling and Shortcut):
#
# If you combine both the **auto-filling** and **shortcut** logic:
# - **If `current` is set**, it will automatically populate both `light` and `dark`.
# - **If `current` is not set**, but both `light` and `dark` are, the system ensures that `current` is set (and vice versa).
#
# You would end up with a very flexible configuration system that minimizes the amount of configuration the user has to input while still offering full flexibility when desired.
#
# ---
#
# ### Let me know how that sounds or if you'd like any further clarifications!
