# Buda-Bot

Buda-Bot is an interactive program made by Cristóbal Fuenzalida for his job interview at Platanus.
Despite the fact that nobody will see this, it was made with joy so it could reach high beauty and flawless functionality.

In order to run buda-bot, the latest stable version of Ruby is recommended (2.7.2).
You can install it easily with Homebrew!

The program requires the following gems:

- Date
- Highline
- HTTP
- JSON

You can install them manually or simply add them using bundle. The Gemfile is included, so all is needed is for the bundle command to be executed locally in the directory where the files are.

Nothing else is required for the program to run, but a unix based terminal is recommended.
Run it yourself!

```sh
$ bundle
$ ruby buda_bot.rb

Using rake 13.0.1
Using public_suffix 4.0.6
Using addressable 2.7.0
Using ast 2.4.1
Using bundler 2.1.4
Using byebug 11.1.3
Using date 3.0.1
Using unf_ext 0.0.7.7
...
Bundle complete! 6 Gemfile dependencies, 27 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.
```

The program is entirely interactive. In order for it to display the desired information, inputs must be given when prompted. Here's an example:

```sh
$ruby buda_bot.rb
 ____________________________________________________________
|                                                            |
|          W E L C O M E    T O    B U D A - B O T!          |
|____________________________________________________________|
|                                                            |
| -- M E N U :                                               |
|                                                            |
| * Show :   's'                                             |
| * Quit :   'q'                                             |
|____________________________________________________________|

  >> q

 ____________________________________________________________
|                                                            |
| Sorry to see you leave...                                  |
| Thank you for using Buda-Bot. See you soon!                |
|____________________________________________________________|
```

## Public Repository

<https://github.com/cristobalfuenzalida/BudaBot>

### License

MIT

### Contact

[c.fuenza6597@gmail.com](mailto:c.fuenza6597@gmail.com)
