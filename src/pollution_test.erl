%%%-------------------------------------------------------------------
%%% @author paste
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. maj 2019 02:36
%%%-------------------------------------------------------------------
-module(pollution_test).
-author("paste").

%% API
-include_lib("eunit/include/eunit.hrl").

monitor_prep() ->
  pollution:addValue("Fifth Avenue", {{2000,10,10},{10,40,10}}, "PM10", 2,
    pollution:addValue("221B Baker Street", calendar:local_time(), "PM10", 4,
        pollution:addValue("Fifth Avenue", {{2000,10,10},{2,10,10}}, "PM10", 50,
          pollution:addStation("Fifth Avenue", {3,4},
            pollution:addValue({0,0}, {{2000,10,10},{12,40,10}}, "PM10", 50,
              pollution:addStation("221B Baker Street", {0,0},
                pollution:createMonitor())))))).

getOneValue_test() ->
  ?assertEqual(50, pollution:getOneValue("Fifth Avenue", {{2000,10,10},{2,10,10}}, "PM10", monitor_prep())).

getDailyMean_test() ->
  ?assertEqual(34.0, pollution:getDailyMean("PM10", {2000,10,10}, monitor_prep())).

getStationMean_test() ->
  ?assertEqual(26.0, pollution:getStationMean({3,4}, "PM10", monitor_prep())).

removeValue_test() ->
  ?assertEqual(50.0, pollution:getStationMean("Fifth Avenue", "PM10",
    pollution:removeValue("Fifth Avenue", {{2000,10,10},{10,40,10}}, "PM10", monitor_prep()))).

getMaximumGradientStations_test() ->
  ?assertEqual({9.6,{3,4},{0,0}}, pollution:getMaximumGradientStations(monitor_prep())).