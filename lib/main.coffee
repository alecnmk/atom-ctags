module.exports =
  configDefaults:
    useEditorGrammarAsCtagsLanguage: true
    autoBuildTagsWhenActive: false
    fileBlacklist: ".*, *.so, *.os, Makefile, README, *.png, *.o, *.a, *.command, *.json, *.sh, *.gif, *.1, *.md"

  activate: ->
    @stack = []

    @ctagsCache = require "./ctags-cache"
    @ctagsCache.activate(atom.config.get('symbols-view.autoBuildTagsWhenActive'))

    @ctagsComplete = require "./ctags-complete"
    @ctagsComplete.activate(@ctagsCache)

    @createFileView()

    atom.workspaceView.command 'symbols-view:rebuild', =>
      @ctagsCache.rebuild()

    atom.workspaceView.command 'symbols-view:toggle-file-symbols', =>
      @createFileView().toggle()

    atom.workspaceView.command 'symbols-view:go-to-declaration', =>
      @createFileView().goto()

    atom.workspaceView.command 'symbols-view:return-from-declaration', =>
      @createGoBackView().toggle()


  deactivate: ->
    if @fileView?
      @fileView.destroy()
      @fileView = null

    if @projectView?
      @projectView.destroy()
      @projectView = null

    if @goToView?
      @goToView.destroy()
      @goToView = null

    if @goBackView?
      @goBackView.destroy()
      @goBackView = null

    @ctagsComplete.deactivate()
    @ctagsCache.deactivate()

  createFileView: ->
    unless @fileView?
      FileView  = require './file-view'
      @fileView = new FileView(@stack)
      @fileView.ctagsCache = @ctagsCache
    @fileView

  createGoBackView: ->
    unless @goBackView?
      GoBackView = require './go-back-view'
      @goBackView = new GoBackView(@stack)
    @goBackView;
