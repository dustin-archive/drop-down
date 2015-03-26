# Drop Down - 1.0.0
# March 26, 2015
# The MIT License (MIT)
# Copyright (c) 2015 Dustin Dowell
# github.com/dustindowell22/drop-down
# ==============================================


(($) ->
  $.fn.dropDown = (toggleClass = 'toggled') ->

    #
    $this = $(this)

    #
    $ul = $this.find('ul')
    $li = $this.find('li')
    $a  = $this.find('a')

    #
    $button           = $ul.siblings($a)               # Buttons are anchors that sister an unordered-list
    $parent           = $button.parent()               # Parents are list-items that parent buttons
    $drawer           = $button.siblings($ul)          # Drawers are unordered-lists sister buttons
    $link             = $a.not($button)                # Links are anchors that are not buttons
    $listItem         = $li.has($a)
    $rootListItem     = $ul.first().find($listItem)    # Root list-items are the first set of list-items in a menu
    $firstListItem    = $listItem.find(':first-child') # First list-items are the first list-items in a list
    $lastListItem     = $listItem.find(':last-child')  # Last list-items are the last list-items in a list
    $nestedList       = $listItem.find($ul)            # Nested lists are unordered-lists that are in a list-item
    $veryLastListItem = $()                            # Very last list-items are the very last list-tems in a nested list
    $toggledListItem  = $()

    #
    $this.find($nestedList).not($nestedList.find($li).find($ul)).each ->
      $nestedListItem = $(this).find($li)
      if $nestedListItem.length
        $veryLastListItem = $veryLastListItem.add($nestedListItem.last())

    #
    $button.click (event) ->
      event.preventDefault()

      # Cached object names in this function are preceded by a 'c'
      $cButton         = $(this)
      $cParent         = $cButton.parent()
      $cUncle          = $cParent.siblings()
      $cDrawer         = $cButton.siblings($ul)
      $cDrawerListItem = $cDrawer.find($li) # These variable names kinda suck
      $cNestedDrawer   = $cDrawer.find($drawer) # These variable names kinda suck
      $cRootListItem   = $cButton.closest($rootListItem)

      #
      if $cParent.hasClass(toggleClass)
        $cParent.removeClass(toggleClass)
        $cDrawer.css('height', '')
        $toggledListItem = $toggledListItem.not($cParent) # Update toggled list-items for filtering when using arrow keys
      else
        $cParent.addClass(toggleClass)
        $toggledListItem = $toggledListItem.add($cParent) # Update toggled list-items for filtering when using arrow keys

      # Reset children
      if $cDrawerListItem.hasClass(toggleClass)
        $cDrawerListItem.removeClass(toggleClass)
        $cNestedDrawer.css('height', '')

      # Reset cousins
      if $cUncle.hasClass(toggleClass)
        $cUncle.removeClass(toggleClass)
        $cUncle.children($drawer).css('height', '')

      # Animate auto
      $drawer.update().reverse().each ->

        # Cached object names in this function are preceded by an 'a'
        $aDrawer = $(this)
        $aParent = $aDrawer.parent()

        if $aParent.hasClass(toggleClass)
          $aClone = $aDrawer.clone().css('display', 'none').appendTo($aParent)
          height = $aClone.css('height', 'auto').height() + 'px'
          $aClone.remove()
          $aDrawer.css('height', '').css('height', height)

    #
    closeMenu = ->
      if $parent.hasClass(toggleClass)
        $parent.removeClass(toggleClass)
        $drawer.css('height', '')

    #
    $link.click ->
      closeMenu()

    #
    $(document).on 'click focusin', (event) ->
      if not $(event.target).closest($button.parent()).length
        closeMenu()

    #
#    $.fn.drawerExists        = -> $(this).next().length # Add filter for next
    $.fn.drawerExists        = -> $(this).nextAll().filter($drawer).length

#    $.fn.drawerOpened        = -> $(this).parent().hasClass(toggleClass) # Add filter for parent
    $.fn.drawerOpened        = -> $(this).closest($listItem).hasClass(toggleClass)

    $.fn.firstChild          = -> $(this).parent().is($firstListItem) # Add filter for parent

#    $.fn.lastChild           = -> $(this).parent().is($lastListItem) # Add filter for parent
#    $.fn.lastChild           = -> $(this).closest($li).is($lastListItem)
    $.fn.lastChild           = -> $(this).closest($listItem).is($lastListItem)

#    $.fn.lastItem            = -> $(this).parent().is($veryLastListItem) # Add filter for parent
#    $.fn.lastItem            = -> $(this).closest($li).is($veryLastListItem)
    $.fn.lastItem            = -> $(this).closest($listItem).is($veryLastListItem) # I don't think this is working correctly.

    # Click actions
    $.fn.toggleDrawer        = -> $(this).click()
    $.fn.closeRootDrawer     = -> $(this).closest($rootListItem).find($a).first().click()
    $.fn.closeParentDrawer   = -> $(this).closest($drawer).prevAll().filter($a).click()

    # Focus actions
    $.fn.focusNextRootDrawer = -> $(this).closest($rootListItem).nextAll().filter($listItem).find($a).first().focus()
    $.fn.focusNextDrawer     = -> $(this).closest($toggledListItem).nextAll().filter($listItem).first().find($a).first().focus() # Focuses the next drawer from inside a list.
    $.fn.focusParentDrawer   = -> $(this).closest($drawer).prevAll().filter($a).first().focus()
    $.fn.focusNextItem       = -> $(this).closest($listItem).nextAll().filter($listItem).first().find($a).first().focus()
    $.fn.focusPreviousItem   = -> $(this).closest($listItem).prevAll().filter($listItem).first().find($a).first().focus()
    $.fn.focusDrawerItem     = -> $(this).nextAll().filter($drawer).first().find($listItem).first().find($a).first().focus()
    $.fn.focusDrawerItemUp   = -> $(this).closest($listItem).prevAll().filter($toggledListItem).first().find($listItem).last().find($a).first().focus() # This variable name kinda sucks

    # Bind arrow keys
    $a.keydown (event) ->
      $this = $(this)

      # Left
      if event.keyCode is 37
        event.preventDefault()
        if $this.drawerOpened()
          $this.toggleDrawer()
        else                            # From here down are the same
          $this.focusPreviousItem()
          if $this.closest($listItem).prevAll().filter($listItem).hasClass(toggleClass) # These need to be in logic functions
            $this.focusDrawerItemUp()

      # Up
      if event.keyCode is 38
        event.preventDefault()
        if $this.firstChild()
          $this.focusParentDrawer()
        else                            # From here down are the same
          $this.focusPreviousItem()
          if $this.closest($listItem).prevAll().filter($listItem).first().hasClass(toggleClass) # These need to be in logic functions
            $this.focusDrawerItemUp()

          # If there's a previous drawer open, focus the last item in that drawer

      # Right
      if event.keyCode is 39
        event.preventDefault()
        if $this.drawerExists()
          if $this.drawerOpened()
            $this.focusDrawerItem()
          else
            $this.toggleDrawer()
        else
          if $this.lastChild()
            if $this.lastItem() # I don't think this is working correctly.
              $this.closeRootDrawer()
              $this.focusNextRootDrawer()
            else
              $this.closeParentDrawer().focusNextItem()
          else
            $this.focusNextItem()

      # Down
      if event.keyCode is 40
        event.preventDefault()
        if $this.lastChild()
          $this.focusNextDrawer()
#          if $this.has($veryLastListItem) # I'm not sure if this is reliable logic for finding the last list?
#            $this.focusDrawerItem()
#          else
        else
          if $this.drawerOpened()
            $this.focusDrawerItem()
          else
            $this.focusNextItem()

    # Allow chaining
    return this

) jQuery
