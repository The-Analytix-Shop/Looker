view: period_over_period {

  extension: required

####################################
#############PARAMETERS#############
####################################

  parameter: exclude_days {
    description: "An optional exclusion of the current date."
    label: "Exclude Days"
    group_label: "Tile or Dashboard Filters"
    view_label: "Period Over Period Framework"
    type: unquoted
    allowed_value: {
      label: "No Exclude"
      value: "0"
    }
    allowed_value: {
      label: "Exclude Current Day"
      value: "1"
    }
    default_value: "0"
  }

  parameter: period_selection {
    description: "The period of dates to base the data on."
    label: "Period Selection"
    view_label: "Period Over Period Framework"
    group_label: "Parameters"
    type: unquoted
    allowed_value: {
      label: "Select a Timeframe"
      value: "none"
    }
    allowed_value: {
      label: "Week to Date"
      value: "wtd"
    }
    allowed_value: {
      label: "Month to Date"
      value: "mtd"
    }
    allowed_value: {
      label: "Quarter to Date"
      value: "qtd"
    }
    allowed_value: {
      label: "Year to Date"
      value: "ytd"
    }
    allowed_value: {
      label: "Last Week"
      value: "lw"
    }
    allowed_value: {
      label: "Last Month"
      value: "lm"
    }
    allowed_value: {
      label: "Last Quarter"
      value: "lq"
    }
    allowed_value: {
      label: "Last Year"
      value: "ly"
    }
    default_value: "none"
  }

  parameter: compare_to_period {
    description: "The period of dates the compare the data on."
    label: "Compare To"
    view_label: "Period Over Period Framework"
    group_label: "Parameters"
    type: unquoted
    allowed_value: {
      label: "Select a Period"
      value: "none"
    }
    allowed_value: {
      label: "Prior Week"
      value: "prior_week"
    }
    allowed_value: {
      label: "Prior Month"
      value: "prior_month"
    }
    allowed_value: {
      label: "Prior Quarter"
      value: "prior_quarter"
    }
    allowed_value: {
      label: "Prior Year"
      value: "prior_year"
    }
    default_value: "none"
  }

  parameter: start_of_week{
    description: "The day that determines the start of the week."
    label: "Start of Week"
    group_label: "Parameters"
    view_label: "Period Over Period Framework"
    type: unquoted
    allowed_value: {
      label: "Monday"
      value: "Monday"
    }
    allowed_value: {
      label: "Sunday"
      value: "Sunday"
    }
    default_value: "Monday"
  }

  parameter: spoof_date {
    description: "Allows 'today' to be based on another day."
    label: "Spoof Date"
    group_label: "Parameters"
    view_label: "Period Over Period Framework"
    type: date
  }

  parameter: timezone {
    description: "The timezone to base 'today' off of."
    label: "Timezone"
    group_label: "Parameters"
    view_label: "Period Over Period Framework"
    type: string
    allowed_value: {
      label: "Select a Timezone"
      value: "UTC"
    }
    allowed_value: {
      label: "America/Los_Angeles"
      value: "America/Los_Angeles"
    }
    allowed_value: {
      label: "America/New_York"
      value: "America/New_York"
    }
    allowed_value: {
      label: "America/Chicago"
      value: "America/Chicago"
    }
    allowed_value: {
      label: "America/Denver"
      value: "America/Denver"
    }
    allowed_value: {
      label: "Europe/London"
      value: "Europe/London"
    }
    allowed_value: {
      label: "Australia/Sydney"
      value: "Australia/Sydney"
    }
    default_value: "UTC"
  }

  parameter: field_used_for_date {
    description: "The field that should be effected by any date logic."
    label: "Field Used For Date Filtering"
    group_label: "Tile or Dashboard Filters"
    view_label: "Period Over Period Framework"
    type: unquoted
    default_value: "date"
  }

####################################
###############LOGIC################
####################################

  dimension: _start_date {
    type: date_raw
    sql:
          {% if spoof_date._parameter_value != 'NULL' %}
            date({% parameter spoof_date %})
          {% else %}
            {% assign _timezone = timezone._parameter_value %}
            {% assign _exclude_days = exclude_days._parameter_value %}
            current_date({{_timezone}}) - {{_exclude_days}}
          {% endif %}
          ;;
    convert_tz: no
    view_label: "Period Over Period Framework"
    group_label: "Period Over Period"
  }

  dimension: _current_period_selection_start {
    type: string
    sql:
          {% if period_selection._parameter_value == 'none' %}
          "No Current Period Selected"
          {% else %}

        {% assign _start_of_week = start_of_week._parameter_value %}
        {%- case period_selection._parameter_value -%}
        {%- when 'wtd' -%}
        date_trunc(${_start_date}, WEEK({{_start_of_week}}))
        {%- when 'mtd' -%}
        date_trunc(${_start_date}, MONTH)
        {%- when 'qtd' -%}
        date_trunc(${_start_date}, QUARTER)
        {%- when 'ytd' -%}
        date_trunc(${_start_date}, YEAR)
        {%- when 'lw' -%}
        date_trunc(date_add(${_start_date}, interval - 1 WEEK({{_start_of_week}}), WEEK({{_start_of_week}}))
        {%- when 'lm' -%}
        date_trunc(date_add(${_start_date}, interval -1 MONTH), MONTH)
        {%- when 'lq' -%}
        date_trunc(date_add(${_start_date}, interval -1 QUARTER), QUARTER)
        {%- when 'ly' -%}
        date_trunc(date_add(${_start_date}, interval -1 YEAR), YEAR)
        {%- else -%}
        ${_start_date}
        {%- endcase %}

        {% endif %}
        ;;
    view_label: "Period Over Period Framework"
    group_label: "Period Over Period"
    convert_tz: no
  }

  dimension: _current_period_selection_end {
    type: string
    sql:
          {% if period_selection._parameter_value == 'none' %}
          "No Current Period Selected"
          {% else %}

        {% assign _start_of_week = start_of_week._parameter_value %}
        {%- case period_selection._parameter_value -%}
        {%- when 'wtd' or 'mtd' or 'qtd' or 'ytd' -%}
        ${_start_date}
        {%- when 'lw' -%}
        last_day(date_add(${_start_date}, interval - 1 WEEK({{_start_of_week}}), WEEK({{_start_of_week}}))
        {%- when 'lm' -%}
        last_day(date_add(${_start_date}, interval -1 MONTH), MONTH)
        {%- when 'lq' -%}
        last_day(date_add(${_start_date}, interval -1 QUARTER), QUARTER)
        {%- when 'ly' -%}
        last_day(date_add(${_start_date}, interval -1 YEAR), YEAR)
        {%- else -%}
        ${_start_date}
        {%- endcase %}

        {% endif %}
        ;;
    view_label: "Period Over Period Framework"
    group_label: "Period Over Period"
    value_format: ""
    convert_tz: no
  }

  dimension: _compare_period_selection_start {
    type: string
    sql:
          {% if compare_to_period._parameter_value =='none'or period_selection._parameter_value == 'none' %}
            cast(null as date)
          {% else %}

        {% assign _start_of_week = start_of_week._parameter_value %}
        {%- case compare_to_period._parameter_value -%}
        {% when "none" %}
        ${_start_date}
        {% when "prior_period" %}

        {% when "prior_week" %}
        date_add(${_current_period_selection_start}, interval -1 WEEK)
        {% when "prior_month" %}
        date_add(${_current_period_selection_start}, interval -1 MONTH)
        {% when "prior_quarter" %}
        date_add(${_current_period_selection_start}, interval -1 QUARTER)
        {% when "prior_year" %}
        date_add(${_current_period_selection_start}, interval -1 YEAR)
        {%- else -%}
        ${_start_date}
        {%- endcase %}

        {% endif %}
        ;;
    view_label: "Period Over Period Framework"
    group_label: "Period Over Period"
    value_format: ""
    convert_tz: no
  }

  dimension: _compare_period_selection_end {
    type: string
    sql:
          {% if compare_to_period._parameter_value =='none'or period_selection._parameter_value == 'none' %}
            cast(null as date)
          {% else %}

        {% assign _start_of_week = start_of_week._parameter_value %}
        {%- case compare_to_period._parameter_value -%}
        {% when "none" %}
        ${_start_date}
        {% when "prior_period" %}

        {% when "prior_week" %}
        date_add(${_current_period_selection_end}, interval -1 WEEK)
        {% when "prior_month" %}
        date_add(${_current_period_selection_end}, interval -1 MONTH)
        {% when "prior_quarter" %}
        date_add(${_current_period_selection_end}, interval -1 QUARTER)
        {% when "prior_year" %}
        date_add(${_current_period_selection_end}, interval -1 YEAR)
        {%- else -%}
        ${_start_date}
        {%- endcase %}

        {% endif %}
        ;;
    view_label: "Period Over Period Framework"
    group_label: "Period Over Period"
    value_format: ""
    convert_tz: no
  }

  dimension: period {
    type: string
    sql:
        {% if compare_to_period._parameter_value =='none'and period_selection._parameter_value == 'none' %}
        "Can't Compute Period Without More Info"
        {% else %}

        case when ${TABLE}.date between ${_current_period_selection_start} and ${_current_period_selection_end}
        then 'Current Period: '|| format_date("%m/%d/%Y", ${_current_period_selection_start}) || " -- " || format_date("%m/%d/%Y", ${_current_period_selection_end})

        when ${TABLE}.date between ${_compare_period_selection_start} and ${_compare_period_selection_end}
        then 'Comparison Period: '|| format_date("%m/%d/%Y", ${_compare_period_selection_start}) || " -- " || format_date("%m/%d/%Y", ${_compare_period_selection_end})

        else 'Other'
        end

        {% endif %}
        ;;
    view_label: "Period Over Period Framework"
    group_label: "Period Over Period"
    value_format: ""
    convert_tz: no
  }

  dimension: sql_always_where {
    type: string
    sql:
        1=1
        {% assign _date = field_used_for_date._parameter_value %}
        {% if period_selection._parameter_value != 'none'%}
        and (${TABLE}.{{_date}} between ${_current_period_selection_start} and ${_current_period_selection_end})
        {% endif %}
        {% if period_selection._parameter_value != 'none' and compare_to_period._parameter_value != 'none' %}
        or
        (${TABLE}.{{_date}} between ${_compare_period_selection_start} and ${_compare_period_selection_end})
        {% endif %}
          ;;
    hidden: yes
  }

}
