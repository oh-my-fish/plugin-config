function config -d "Get and set package configuration" -a package action key value
  # Check if the user needs some help.
  if begin; not set -q argv[1]; or contains -- -h $argv; or contains -- --help $argv; end
    test "$package" = -h
      or test "$package" = --help
      and set package ""

    config.help "$package"
    return 0
  end

  if test -z "$package" -o "$package" = . -o "$package" = ..
    echo "You must specify a valid package name."
    return 1
  end

  # Match the action given.
  switch "$action"
    case -l --list ''
      for file in $OMF_CONFIG/$package/**
        if test -f "$file"
          printf "%s=%s\n" (realpath --relative-base="$OMF_CONFIG/$package" "$file" | tr -s '/' '.') (cat $file)
        end
      end

    # For any of the below actions, we need to do some additional
    # argument parsing.
    case -g --get -q --query -s --set -u --unset
      if test -z "$key"
        echo "You must specify a key name."
        return 1
      end

      # Expand the key name into a directory tree.
      set key (echo -n "$key" | tr -s '.' '/')

      # Match which of the above actions was given.
      switch "$action"
        case -g --get
          if begin; test "$value" = -d; or test "$value" = --default; end
            if not set -q argv[5]
              echo "You must specify a default value."
              return 1
            end

            set default "$argv[5]"
          end

          if test -f $OMF_CONFIG/$package/$key
            cat $OMF_CONFIG/$package/$key
          else if set -q default
            echo -n "$default"
          else
            return 1
          end

        case -q --query
          test -f $OMF_CONFIG/$package/$key

        case -s --set
          mkdir -p (dirname $OMF_CONFIG/$package/$key)

          # Check for any additional options.
          switch "$value"
            case ''
              echo "You must specify a value to set."
              return 1

            case -e --edit
              set -l editor "$EDITOR"
              if not set -q EDITOR
                echo "No editor in `\$EDITOR` is specified."

                if available vim
                  set editor vim
                else if available nano
                  set editor nano
                else
                  return 1
                end

                echo "Using `$editor` as editor."
              end

              eval $editor $OMF_CONFIG/$package/$key

            case '*'
              echo -n "$value" > $OMF_CONFIG/$package/$key
          end

        case -u --unset
          rm $OMF_CONFIG/$package/$key
      end

    case '*'
      echo "Unknown action '$action'."
      config.help "$package"
      return 1
  end
end
