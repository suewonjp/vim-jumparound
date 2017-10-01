# VIM-JUMPAROUND

### :coffee: DESCRIPTION
This plugin provides mappings and commands for:

- Quick Jump between Tab Pages/Windows/Marks
- Quick Text Search
- Easy Use of Quickfix List
- Quick Invocation of File Explorer
- Etc.

### :coffee: QUICK USAGE OVERVIEW

> **[NOTE]** This plugin is only available if 'compatible' is not set and  
> Vim version is 8.0 or later

#### :small_orange_diamond: Quick Jump between Tab Pages ( :help ja-jump-to-tab-page )

Type `<M-l>` (ALT + L) to jump to the right tab page (same as `gt`) and type `<M-h>` (ALT + H) jump to the left tab page (same as `gT`).

> **[What's the advantage?]** These mappings would work in not only Normal mode, but also Insert mode, Command mode.

Type `1<TAB>` to jump to the 1st tab page and `2<TAB>` to jump to the 2nd tab page and so on.  
Typing `0<TAB>` will let you jump to the previously accessed tab page.

#### :small_orange_diamond: Quick Jump between Windows ( :help ja-jump-to-windows )

Type `<M-K>` (ALT + SHIFT + K) to jump to the window above. (Same as `<C-w>k`)  
Type `<M-J>` (ALT + SHIFT + J) to jump to the window below. (Same as `<C-w>j`)  
( Also `<M-H>` and `<M-L>` are equivalent to `<C-w>h` and `<C-w>l`, respectively )

> **[What's the advantage?]** These mappings would work in not only Normal mode, but also Insert mode, Command mode.  
> Also, the cursor movement will be wrapped.  
> For example, Vim's builtin window movement command `<C-w>L` would get stuck at the right most window.  
> However, `<M-L>` will let you go to the left most window in that case.

Type `1<CR>` to jump to the 1st window which is the top left window and type `2<CR>` to jump to the 2nd window and so on.  
Typing `0<CR>` will let you jump to the previously accessed window.

#### :small_orange_diamond: Quick Jump between Marks ( :help ja-jump-to-marks )

Type `<SPACE>m` to jump to the mark `m` (Same as typing \`m)

> **[What's the advantage?]** Depending on the keyboard layout, the location of ' or \` key is inconsistent.  
> ( The japanese keyboard layout and US keyboard layout differ. Also laptops have different keyboard layouts. )   
> `<SPACE>m` would let you forget the location of the keys when you use multiple machines ( And it is easier to type )

`0<SPACE>` is equivalent to \`\` command, which lets you jump to the position before the last jump.

#### :small_orange_diamond: Quick Invocation of File Explorer
Type `<M-t>` to open a file explorer in a new tab page.

Type `<M-x>` to open a file explorer in a new vertical split window. ( Type `<M-x>` again, to close it )

#### :small_orange_diamond: Quick Text Search ( :help ja-quick-search )
`sa` will search the argument-list for the pattern stored in `@/` register and automatically open the Quickfix window.

`sf` will search files under the current working directory for the pattern stored in `@/` register and automatically open the Quickfix window.

`#a` will search the argument-list for `<cword>` and automatically open the Quickfix window.

`#f` will search files under the current working directory for `<cword>` and automatically open the Quickfix window.

`#a` and `#f` will also work for arbitrary text selected in the Visual mode.

> Also, this plugin will let `*` and `#` command work for arbitrary text selected in the Visual mode just like they work for `<cword>`.  


These search related mappings can be configured further using `g:ja_search_mapleader` variable. For instance, define it like so in your .vimrc:

	let g:ja_search_mapleader = '<C-g>'

Then, you can prefix `<C-g>` for every quick search mappings in the plugin.
( `<C-g>sa` for `sa`, `<C-g>#f` for `#f,` and so on )

#### :small_orange_diamond: Easy Use of Quickfix List ( :help ja-quickfix )
`qft` will toggle the Quickfix window. While it is open, `q<CR>` will let you quickly jump to the Quickfix window from any other windows.

The following mappings are available for the Quickfix and Location-list windows.

    x       Open file and close the quickfix window.

    s       Open file maintaining focus on the window.

    t       Open in a new tab.

    T       Open in a new tab maintaining focus on the window.

    _       Open in a new horizontal split window.

    __      Open in a new horizontal split window maintaining focus on the window.

    |       Open in a new vertical split window.

    ||      Open in a new vertical split window maintaining focus on the window.


#### :small_orange_diamond: Configuration ( :help ja-configuration )
If mappings of this plugin conflict with your existing mappings, you can use one of many global variables provided by the plugin to configure.

For instance, when you already defined many ALT key mappings and they conflict with the mappings of the plugin and you prefer your own mappings, then disable the ALT key mappings of the plugin by assigning 1 to the following variable in your .vimrc:

    let g:ja_bind_alt_meta_mappings = 0

Also you can override default mappings using internal mapping names. For example:

    nmap <leader>q <Plug>JumparoundToggleQuickfix

will let you use `<leader>q` to toggle the Quickfix window instead of the default mapping `qft`.  
( `:help ja-mapping-override` for the complete list of the internal mapping names. )

> **[TIP]** Use `g:ja_check_mapping_confliction` variable to check if mappings in the plugin conflict with your existing mappings.  
> Define it in your .vimrc like so and remove it if you have no issue or after you have resolved any conflict.  

    let g:ja_check_mapping_confliction = 1

### :coffee: HOW TO INSTALL
Use your preferred installation method or install it via [pathogen.vim](https://github.com/tpope/vim-pathogen) like so:

    cd ~/.vim/bundle
    git clone https://github.com/suewonjp/vim-jumparound

After installation, view the manual with `:help jumparound`

### :copyright: COPYRIGHT/LICENSE/DISCLAIMER

    Copyright (c) 2017 Suewon Bahng, suewonjp@gmail.com

#### :small_orange_diamond: License

Same terms as Vim itself. See [LICENSE.txt](LICENSE.txt) or type `:help license` in your Vim editor 

* * *
Updated by Suewon Bahng ( Sep 2017 )

