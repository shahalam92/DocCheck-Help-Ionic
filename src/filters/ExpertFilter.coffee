# CommaSeperator filter

angular.module("Help.filters").filter('expertFilter', (ExpertFilter) ->
  return (experts) ->
    filtered = experts.filter(( expert ) ->
      return !ExpertFilter.isExpertFiltered( expert )
    )

    ExpertFilter.setResultAmount( filtered.length )

    return filtered
)