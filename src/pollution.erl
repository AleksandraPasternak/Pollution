%%%-------------------------------------------------------------------
%%% @author paste
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. kwi 2019 15:13
%%%-------------------------------------------------------------------
-module(pollution).
-author("paste").

%% API
-export([createMonitor/0, addStation/3,addValue/5,addUniqueValue/6, removeValue/4, getOneValue/4, getStationMean/3, uniqueTypes/1]).
-export([meanByStation/4, length/2, mean/1,getDailyMean/3]).
-export([getMaximumGradientStations/1,distance/2, maxOfType/3, nameToCoordinates/2, getMaxGradient/4, gradient/4, absolute/1]).

-record(station, {name, coordinates}).
-record(data, {id, date, type}).
-record(monitor, {stationMap, dataMap}).

createMonitor() -> #monitor{stationMap = #{}, dataMap = #{}}.

addStation(Name, Coordinates, #monitor{stationMap = Stations, dataMap = Data}) ->
  case maps:is_key(Name, Stations) orelse maps:is_key(Coordinates, Stations) of
    true -> throw("This station already exist");
    _ -> Station = #station{name = Name, coordinates = Coordinates},
      #monitor{stationMap = Stations#{Coordinates => Station, Name => Station}, dataMap = Data}
  end.

addValue(Id, Date, Type, Value, #monitor{stationMap = Stations, dataMap = Data}) ->
  case maps:is_key(Id, Stations) of
    false -> throw("This station does not exist");
    _ -> addUniqueValue(Id, Date, Type, Value, Stations, Data)
  end.

addUniqueValue(Id, Date, Type, Value, Stations, Data) ->
  case maps:is_key(#data{id = Id, date = Date, type = Type}, Data) of
    true -> throw("This measurment already exist");
    _ -> Measurement = #data{id=Id, date=Date, type=Type},
      #monitor{stationMap = Stations, dataMap = Data#{Measurement => Value}}
  end.

removeValue(Id, Date, Type, #monitor{stationMap = Stations, dataMap = Data}) ->
  case maps:is_key(#data{id = Id, date = Date, type = Type}, Data) of
    false -> throw("This value does not exist");
    true ->
      maps:remove(#data{id=Id, date = Date, type = Type}, Data),
      #monitor{stationMap = Stations, dataMap = Data}
  end.

getOneValue(Id, Date, Type, #monitor{stationMap = _, dataMap = Data}) ->
  maps:get(#data{id=Id, date =Date, type = Type}, Data, "There is no measurement with this atributes").

getStationMean(Id, Type, #monitor{stationMap = Stations, dataMap = Data}) ->
  case maps:is_key(Id, Stations) of
    false -> throw("Station does not exist");
    true ->
      case is_tuple(Id) of
        true -> meanByStation(Data, Type, Id, (maps:get(Id, Stations))#station.name);
        false -> meanByStation(Data, Type, Id, (maps:get(Id, Stations))#station.coordinates)
      end
  end.

meanByStation(Data, TypeMean, IdMean, IdMean2) ->
  mean(maps:values(maps:filter(
    fun(#data{id=Id, date=_, type = Type},_) ->
      (Id==IdMean orelse Id==IdMean2) andalso Type==TypeMean end,
    Data))).

mean(List) ->
  case length(List,0) of
    0-> throw("There are no measurements. Cannot compute mean therefore.");
    _-> lists:sum(List) / length(List,0)
  end.


length([],Sum)->Sum;
length([_|B],Sum)->length(B, 1+Sum).

getDailyMean(TypeMean, Day, #monitor{stationMap = _, dataMap = Data}) ->
  mean(maps:values(maps:filter(
    fun(#data{id=_, date=Date, type=Type},_)->
      (Day==element(1,Date) andalso Type==TypeMean) end,
    Data))).

getMaximumGradientStations(#monitor{stationMap = Stations, dataMap = Data}) ->
  getMaxGradient(Stations, Data, uniqueTypes(maps:filter(
    fun(#data{id=_, date=_, type = Type},_) -> Type/="temperatura" end,
    Data)), {0,{-100,-100},{-100,-100}}).

uniqueTypes(Map) ->
  sets:to_list(sets:from_list([ (element(1,X))#data.type || X<-maps:to_list(Map)])).

getMaxGradient(_,_, [],Max) ->
  case Max of
    {0,{-100,-100},{-100,-100}} ->
      throw("Lack of measurements for gradient computation. Required at least one parameter measured at 2 different stations.");
    _ -> Max
  end;
getMaxGradient(Stations, Data, [TypeGradient|Tail], Max) ->
  getMaxGradient(Stations,Data,Tail,
    maxOfType(Stations, maps:filter(fun(#data{id=_,date=_, type=Type},_)->Type==TypeGradient end, Data), Max)).

maxOfType(Stations, DataOfType, Max) ->
  foldType([gradient( element(2,X), element(2,Y), nameToCoordinates(Stations, (element(1,X))#data.id),
    nameToCoordinates(Stations, (element(1,Y))#data.id) ) ||
    X<-maps:to_list(DataOfType), Y<-maps:to_list(DataOfType), X/=Y],
    Max).

foldType([],Max) -> Max;
foldType([Head|Tail],Max) ->
  NewMax=lists:foldl(fun({W,Coo1,Coo2},Acc)->max({W,Coo1,Coo2},Acc) end, Head, Tail),
  if
    NewMax>Max -> NewMax;
    true->Max
  end.

nameToCoordinates(Stations, Id) ->
  case is_tuple(Id) of
    true -> Id;
    false -> (maps:get(Id,Stations))#station.coordinates
  end.

gradient(A1, A2, Coo1, Coo2) ->
  { (absolute(A2-A1) / distance(Coo1, Coo2)) , Coo1, Coo2}.

distance({X1,Y1},{X2,Y2}) ->
  math:sqrt(math:pow(X2-X1,2)+math:pow(Y2-Y1,2)).

absolute(X) ->
  if
    X>=0 ->X;
    true -> (-X)
  end.