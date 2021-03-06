lib: pkgs:

with pkgs;

# Lists the packages as attribute sets as if you were in
# `<nixpkgs/pkgs/top-level/all-packages.nix>`.
# They will be added to `pkgs` or override the existing ones.
# Of course, packages can depend on each other, as long as there is no cycle.
let
  yarnpkgs = rec
{
  callPackage = newScope yarnpkgs;
  # Custom xelatex collection
  xelatex = texlive.combine {
    # FIXME: No xelatex for now because Nix derivations seem out of date
    inherit (texlive) scheme-medium;
  };
  
  # Wayland stuff
  wlc = callPackage ./wlc { };
  sway = callPackage ./sway { };
  mpv-wayland = pkgs.mpv.override {
    vaapiSupport = true;
    waylandSupport = true;
  };

  qutebrowser = qt5.callPackage ./qutebrowser {
    inherit (python3Packages) buildPythonApplication pyqt5 jinja2 pygments pyyaml pypeg2 cssutils;
    inherit (gst_all_1) gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav;
  };
  
  # Custom idris packages collection
  idris = pkgs.haskell.packages.ghc7103.idris;
  idrisPackages = import ./idris-packages (pkgs.idrisPackages.override {
    inherit idris;
  });

  # CNTouch driver
  cntouch = callPackage ./cntouch {
    kernel = linux;
  };

  alacritty = callPackage ./alacritty { };
  
  eve-online = callPackage ./eve-online { };
  
  # Dev stuff
  dev = {
    # Enables the use of last OpenGL versions
    mesa_drivers = mesaDarwinOr (
      let mo = mesa_noglu.override {
        enableTextureFloats = true;
        llvmPackages = llvmPackages_36; # various problems with 3.7; see #11367, #11467
      };
      in mo.drivers
    );
    
    # Git snapshot of libwebsockets
    libwebsockets = callPackage ./libwebsocket { };
  };
  
  # Stuff that I maintain
  maintenance = {
    asciidoctor = callPackage ./asciidoctor { };
  };
  
};

in yarnpkgs
