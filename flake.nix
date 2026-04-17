{
  description = "ZerataX's Neovim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};

      # External packages neovim needs on PATH
      runtimeDeps = with pkgs; [
        # compilers / build tools
        gcc
        gnumake
        unzip
        cargo
        rustc

        # language servers
        clang-tools # clangd
        lua-language-server
        nil # nix lsp
        nixd # nix lsp
        pyright
        ruff # python lsp + formatter
        rust-analyzer
        vtsls # typescript/javascript
        typescript-language-server
        vue-language-server
        vscode-langservers-extracted # html, eslint, css, json
        taplo # toml lsp
        nushell # nushell lsp (the shell itself)
        wgsl-analyzer

        # formatters
        stylua
        alejandra # nix formatter
        biome # js/ts formatter

        # linters
        markdownlint-cli

        # debug adapters
        delve # go
        python3Packages.debugpy

        # other
        gdb
        nodejs # needed for vtsls and other node-based tools
      ];

      neovimConfig = pkgs.stdenv.mkDerivation {
        pname = "zeratax-nvim-config";
        version = "0.1.0";
        src = pkgs.lib.cleanSource ./.;
        installPhase = ''
          mkdir -p $out
          cp init.lua $out/
          cp -r lua $out/
        '';
      };

      wrappedNeovim = pkgs.wrapNeovim pkgs.neovim-unwrapped {
        withNodeJs = true;
        withPython3 = true;
        wrapperArgs = [
          "--suffix"
          "PATH"
          ":"
          (pkgs.lib.makeBinPath runtimeDeps)
        ];
        configure = {
          customRC = ''
            lua << EOF
            local config_path = "${neovimConfig}"
            vim.g.nix_config_path = config_path
            vim.opt.rtp:prepend(config_path)
            package.path = config_path .. "/lua/?.lua;" .. config_path .. "/lua/?/init.lua;" .. package.path
            dofile(config_path .. "/init.lua")
            EOF
          '';
          packages.myPlugins = {
            start = with pkgs.vimPlugins; [
              telescope-fzf-native-nvim
            ];
          };
        };
      };
    in {
      default = wrappedNeovim;
      config = neovimConfig;
    });
  };
}
