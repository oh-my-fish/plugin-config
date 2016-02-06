<div align="center">
  <a href="http://github.com/oh-my-fish/oh-my-fish">
    <img width="90px"  src="https://cdn.rawgit.com/oh-my-fish/oh-my-fish/e4f1c2e0219a17e2c748b824004c8d0b38055c16/docs/logo.svg">
  </a>
</div>

# config
Plugin for [Oh My Fish][omf-link].

Standardized tool for loading and saving configuration variables for your plugins.


## Setup
To use `config` in your plugin, first add it to your plugin's `bundle` file:

    package config

You can now start using `config` in your plugin.


## Getting and setting values
Every config value is grouped under a namespace. To access your plugin's settings, you need to choose a namespace to keep all of your settings in. The name of your plugin is usually a good choice.

Reading a config value looks like this:

    config my-namespace --get my-property

For all of `config`'s actions, the namespace must always be the first argument. In the above command, the value of the `my-property` _key_ in the `my-namespace` _namespace_ will be printed to standard output.

Key names can have their own hierarchy. To add additional layers of grouping, you can separate names with a dot (`.`):

    config my-namespace --get misc.colors.header

The nesting isn't just a nice convention; the nesting will actually be reflected in the storage backing (more on that in a bit).

Setting values is similar to getting them. We can set `misc.colors.header` to `red` as follows:

    config my-namespace --set misc.colors.header red

If you need to check what all of your config values are at once, you can see a pretty list of key-value pairs with

    config my-namespace --list

There are more operations than just getting and setting that you can do on your configuration. Check the output of `config --help` for a complete list of actions and options.


## Config files
Config values are stored in individual files and directories in `$OMF_CONFIG`. A directory is created for each namespace to hold config files at `$OMF_CONFIG/my-namespace`.

Each key gets its own file inside the namespace directory. For example, if you have a key called `email` in a `mailer` namespace, you can expect a file at `$OMF_CONFIG/mailer/email` to exist, which contains as text the value of that key. If a key is nested, like our `misc.colors.header` example from earlier, each level of nesting is made into a directory separator. `misc.colors.header` then would be stored in `$OMF_CONFIG/namespace/misc/colors/header`.

Note that a key cannot hold both subkeys and a value.


## Command-line config editing
There's a reason why the `config` command has slightly odd ordering of arguments. You can easily embed the `config` command into your own plugin with minimal effort. Let's say you develop a plugin called `fancy-echo` that prints out text prefixed with a configurable string. A good way to store this string would be in the `prefix` key under the `fancy-echo` namespace. In our plugin, we can read that property with

    config fancy-echo --get prefix

Now if the user wants to change this value without opening up and editing the corresponding config file, the user can use the `config` command themselves:

    config fancy-echo --set prefix "This just in: "

We can make this easier by copying Git's `config` command syntax:

```fish
function fe -d "Fancy echo"
  if begin; set -q argv[1]; and test "$argv[1]" = config; end
    # Pass arguments on to `config`
    config fancy-echo $argv[2..-1]
    return
  end
end
```

Now we can edit `fancy-echo`'s config with `fancy-echo`'s own command!

    fe config --set prefix "This just in: "

If the user needs some help, they can still use `fe config --help`; the help text will adapt automatically to match the package it is embedded in.


## License
[MIT][mit] © [coderstephen][author] et [al][contributors]


[mit]:            http://opensource.org/licenses/MIT
[author]:         http://github.com/coderstephen
[contributors]:   https://github.com/oh-my-fish/plugin-config/graphs/contributors
[omf-link]:       https://www.github.com/oh-my-fish/oh-my-fish
[license-badge]:  https://img.shields.io/badge/license-MIT-007EC7.svg?style=flat-square
