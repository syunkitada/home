# Playground

## How to play

1. Setup playground

```
$ make playground
```

2. Login to playground

```
$ docker exec -it home-rocky9 bash
[playground@home-rocky9 ~]$
```

3. cd home and make setup

```
[playground@home-rocky9 ~]$ cd home
[playground@home-rocky9 home]$ make setup
```

4. Check zsh and vim behavior

```
[playground@home-rocky9 home]$ zsh
```

When you start vim at first time, you will see errors.
However, these errors are only the behavior of the initial loading of the plugin, so you can ignore these errors.

```
#
12:26 [0] playground@home-rocky9:~/home
$ vim
...
:exit
```

On the second startup, look at the :messages and make sure there are no errors or warnings.

```
12:26 [0] playground@home-rocky9:~/home
$ vim
...
:messages
```
