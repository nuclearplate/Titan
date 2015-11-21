Q = require 'Q'
Stream = require '../models/stream'

class SummaryController

  summary: (req, res) ->

    mapper = ->
      emit 'user:' + @user, 1
      emit 'name:' + @name, 1
      return

    reducer = (type, counts) ->
      total = 0
      for index of counts
        total += Number(counts[index])
      total

    opts = 
      out: 'tmp_collection'
      map: mapper
      query: {}
      reduce: reducer

    Q.ninvoke(Stream, 'mapReduce', opts).then (results) ->
      model = results[0]
      stats = results[1]

      model.find (err, totals) ->
        console.log 'TOTALS', arguments
        retval = {}
        iTotal = 0
        
        while iTotal < totals.length
          split = totals[iTotal]._id.split(':')
          type = split[0]
          value = split[1]
          count = totals[iTotal].value
          if retval[type] == undefined
            retval[type] = {}
          if retval[type][value] == undefined
            retval[type][value] = {}
          retval[type][value] = count
          ++iTotal
        res.json retval

module.exports = SummaryController
