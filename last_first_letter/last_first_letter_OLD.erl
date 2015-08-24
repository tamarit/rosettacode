-module(last_first_letter).
-export([main/0]).

main() ->
	StringOfStrings = 
%	  "audino bagon baltoy banette bidoof braviary bronzor carracosta charmeleon " ++
%	  "cresselia croagunk darmanitan deino emboar emolga exeggcute gabite " ++ 
%	  "girafarig gulpin haxorus heatmor heatran ivysaur jellicent jumpluff kangaskhan " ++
%	  "kricketune landorus ledyba loudred lumineon lunatone machamp magnezone mamoswine ",

	  "audino bagon baltoy banette bidoof braviary bronzor carracosta charmeleon " ++
	  "cresselia croagunk darmanitan deino emboar emolga exeggcute gabite " ++
	  "girafarig gulpin haxorus heatmor heatran ivysaur jellicent jumpluff kangaskhan " ++
	  "kricketune landorus ledyba loudred lumineon lunatone machamp magnezone mamoswine " ++
	  "nosepass petilil pidgeotto pikachu pinsir poliwrath poochyena porygon2 " ++
	  "porygonz registeel relicanth remoraid rufflet sableye scolipede scrafty seaking " ++
	  "sealeo silcoon simisear snivy snorlax spoink starly tirtouga trapinch treecko " ++
	  "tyrogue vigoroth vulpix wailord wartortle whismur wingull yamask",
	StringList = string:tokens(StringOfStrings, " "),
	G = digraph:new(),
	get_identities(StringList,1,G),
	get_possible_comb(digraph:vertices(G),G), 
	StartingVertices = [V || V <- digraph:vertices(G), 
	                         digraph:in_degree(G,V) =:= 0,  
	                         digraph:out_degree(G,V) > 0],
	io:format("StartingVertices: ~p\n",[StartingVertices]),
	Memo = ets:new(memo,[set]),
	Paths = get_all_paths([33],[],G,Memo), %get_all_paths(StartingVertices,G),
	io:format("Paths: ~p\n",[Paths]),
	%ets:new(comb,set),
	%OnlyLinkable = [Id || {Id,_,I,O} <- PossibleComb, ((I=/=[]) or (O =/=[]))],
	%GetComb = get_all_combinations(lists:reverse(OnlyLinkable),[],OnlyLinkable),
	%Comb = get_all_combinations(StringList),
%	Reachables = get_reachables(digraph:vertices(G),G),
%	io:format("Reachables: ~p\n",[lists:sort(Reachables)]),
	FunMax = fun(List,Current = {_, CurrMaxVal}) -> 
			case length(List) > CurrMaxVal of
			     true -> {List,length(List)};
			     false -> Current
			end
		 end,
	{Max,MaxLength} = lists:foldl(FunMax, {[],0}, Paths),
	io:format("Max: ~p\n Length: ~p\n",[Max,MaxLength]),
%	io:format("Path: ~p\n",[digraph: get_path(G, 33, 1)]),
	dot_graph_file(G),
	digraph:delete(G),
	ok.
	%io:format("PossibleComb: ~p\n",[OnlyLinkable]),
	%ets:delete(comb).
	
	
get_identities([H | T],Id,G) -> 
	digraph:add_vertex(G,Id,H),
	get_identities(T,Id+1,G);
get_identities([],_,_) -> 
	ok.
	

get_possible_comb([ V | Vs],G) ->
	{V,S} = digraph:vertex(G,V),
	[digraph:add_edge(G,V,V_) || V_ <- digraph:vertices(G) -- [V], 
	                             begin {V_,S_} = digraph:vertex(G,V_),
	                                   lists:last(S) =:= hd(S_)
	                             end],
	%Output = [Id_ || {Id_,S_} <- StringList -- [H], lists:last(S_) =:= hd(S) ],
	get_possible_comb(Vs,G);
get_possible_comb([],_) ->
	ok.
	
get_all_paths([V|Vs],Visited,G,Memo) -> 
	Children_ = digraph:out_neighbours(G, V),
	Children = Children_ -- Visited,
	FunCalculate = 
	   fun() ->
	   	PathsChildren_ = get_all_paths(Children,[V|Visited],G,Memo),
	        ets:insert(Memo,{V,PathsChildren_,[V|Visited]}),
	        PathsChildren_
	   end,
	PathsChildren = 
	   case ets:lookup(Memo, V) of
	        [] ->
	           FunCalculate();
	        [{V,PathsChildren_,Visited_}] -> 
	           DiffVisited = [V|Visited] -- Visited_,
	           Reachable = digraph_utils:reachable(Children, G),
	           IsComplete = 
	              lists:any(fun(PV) -> lists:member(PV,Reachable) end, DiffVisited),
	           %io:format("\nCurrent Visited: ~w\nPrevious Visited: ~w\nComplete: ~p\n",[lists:sort([V|Visited]),lists:sort(Visited_),IsComplete]),
	           case IsComplete of
	                true -> PathsChildren_;
	                false -> FunCalculate()
	           end
	   end,
	PathsFromV = 
		case PathsChildren of
		     [] -> [[V]];
		     _ -> [ [V|Path] || Path <- PathsChildren]
		end,
	PathsFromV ++ get_all_paths(Vs,Visited,G,Memo);
get_all_paths([],_,_,_) ->
	[]. 	

%get_reachables([V|Vs],G) ->
%	[{V,digraph_utils:reachable([V],G)} | get_reachables(Vs,G)];
%get_reachables([],_) -> [].

%get_all_combinations([Id | T],All,All,Acc) -> 
%	Acc;
%get_all_combinations([Id | T],Done,All,Acc) -> 
%	{Id,_I,_} = hd(ets:(lookup(comb, Id))),
%	get_all_combinations([Id | T],[H|],All,Acc);
%get_all_combinations([],_) -> 
%	[].
	
dot_graph_file(G) ->
	file:write_file("graph.dot", list_to_binary("digraph POK {\n"++dot_graph(G)++"}")),
	os:cmd("dot -Tpdf graph.dot > graph.pdf").	
	
dot_graph(G)->
	Vertices = [digraph:vertex(G,V) || V <- digraph:vertices(G)],
	Edges = [{V1,V2}||V1 <- digraph:vertices(G),V2 <- digraph:out_neighbours(G, V1)],
	lists:flatten(lists:map(fun dot_vertex/1,Vertices))++
	lists:flatten(lists:map(fun dot_edge/1,Edges)).
	
dot_vertex({V,L}) ->
	get_id(V) ++" "++"[shape=ellipse, label=\""
	++get_id(V)++" .- " 
	++ L ++ "\"];\n".     
	    
dot_edge({V1,V2}) -> 
	get_id(V1)++" -> "++ get_id(V2)
	++" [color=black, penwidth=3];\n".

	
get_id(V) when is_integer(V) ->
	integer_to_list(V);
get_id(V) when is_list(V) ->
	lists:foldr(fun(V_,Acc) -> Acc ++ integer_to_list(V_) end,"",V).
	
%get_all_combinations([],Acc) -> 
%	Acc;
%get_all_combinations([H | T],[]) -> 
%	get_all_combinations(T,[H]);
%get_all_combinations([H | T],Acc) ->
%	case lists:last(lists:last(Acc)) =:= hd(H) of
%	     true ->
%	     	get_all_combinations(T,Acc ++ [H]);
%	     false -> 
%	     	get_all_combinations(T,Acc)
%	end.
	    	
%get_all_combinations([]) -> [];
%get_all_combinations([S]) -> [S];
%get_all_combinations(List) ->
%	[[S1, S2] ++  
%	    [T || T <- get_all_combinations(List-- [S1,S2]), 
%	          hd(hd(T)) =:= lists:last(S2)] 
%	 || S1 <- List, S2 <- List -- [S1],  
%	    hd(S2) =:= lists:last(S1)].
	