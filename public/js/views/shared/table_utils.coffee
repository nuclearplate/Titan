
TableUtils =

  indexCell: ->
    {
      editable: false
      sortable: false
      label: "Index"
      cell: Backgrid.IntegerCell.extend
        render: ->
          @$el.empty()
          index = @model.collection.indexOf(@model) + 1
          # index += this.model.collection.state.pageSize * (this.model.collection.state.currentPage - 1)
          @$el.text(@formatter.fromRaw(index))
          @$el.css 'text-align', 'center'
          @delegateEvents()
          return @
    }

  textLinkToSelf: (key, label, getUrl) ->
    {
      editable: false
      sortable: false
      label: label
      cell: Backgrid.IntegerCell.extend
        render: ->
          @$el.empty()
          @$el.html """
            <a href="##{getUrl(@model)}">#{@model.get(key)}</a>
          """
          @$el.css 'text-align', 'center'
          @delegateEvents()
          return @
    }

  arrayLinkToSelf: (key, label, getUrl) ->
    {
      editable: false
      sortable: false
      label: label
      cell: Backgrid.IntegerCell.extend
        render: ->
          @$el.empty()

          array = @model.get(key) || []

          @$el.html """
            <a href="##{getUrl(@model)}">[ #{array.join(', ')} ]</a>
          """
          @$el.css 'text-align', 'center'
          @delegateEvents()
          return @
    }

  arrayLengthLinkToSelf: (key, label, getUrl) ->
    {
      editable: false
      sortable: false
      label: label
      cell: Backgrid.IntegerCell.extend
        render: ->
          @$el.empty()

          array = @model.get(key) || []

          @$el.html """
            <a href="##{getUrl(@model)}">#{array.length}</a>
          """
          @$el.css 'text-align', 'center'
          @delegateEvents()
          return @
    }

  button: (label, onClick) ->
    {
      editable: false
      sortable: false
      label: label
      cell: Backgrid.Cell.extend
        render: ->
          @$el.empty()
          guid = uuid.v1()

          @$el.html """
            <a class="btn btn-default table-button-#{guid}" href="javascript:void(0)">#{label}</a>
          """

          @$(".table-button-#{guid}").on 'click', (event) =>
            onClick event, @model

          @$el.css 'text-align', 'center'
          @delegateEvents()
          return @
    }

  wholeObjectJSONPopup: ->
    {
      cell: Backgrid.IntegerCell.extend
        className: "string-cell sortable centered-string-cell"
        formatter: Backgrid.StringFormatter
        render: ->
          @$el.empty()

          data = @model.attributes
          if data.data isnt undefined and data.data.constructor is String
            try
              data.data = JSON.parse data.data
            catch err
              console.log "FAILED TO PARSE DATA", err                

          index = @model.collection.indexOf @model
          @$el.html """
            <button type="button" stepIndex="#{index}" class="btn btn-default view-data-button">
              Data
            </button>
          """

          @$('.view-data-button').on 'click', (event) =>
            event.preventDefault()

            dialog = vex.open
              contentCSS:
                width: 1200
              content: """
                <div class="container data-container"></div>
                <br>
                <a class="btn btn-lg btn-primary close-button">Close</a>
                <a class="btn btn-lg btn-primary copy-button">Copy to Clipboard</a>
              """
              afterOpen: (value) =>
                $('.close-button').on 'click', (event) => vex.close @dialog.data().vex.id
                $('.copy-button').on 'click', (event) => clipboard.copy JSON.stringify data, null, 2

                $('.data-container').JSONView data, {collapsed: true}
                $('.data-container').JSONView 'expand', 1

          return @
      name: 'data'
      label: 'Data'
      className: 'agent-name-cell'
      editable: false
      sortable: true
    }

module.exports = TableUtils