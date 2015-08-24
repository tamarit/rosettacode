-module(last_first_letter).
-export([main/0]).

-export([find_links/3]).

main() ->
	StringOfStrings = 
%	  "audino bagon baltoy banette bidoof braviary bronzor carracosta charmeleon " ++
%	  "cresselia croagunk darmanitan deino emboar emolga exeggcute gabite " ++ 
%	  "girafarig gulpin haxorus heatmor heatran ivysaur jellicent jumpluff kangaskhan " ++
%	  "kricketune landorus ledyba loudred lumineon lunatone machamp magnezone mamoswine " ++
%	  "nosepass petilil pidgeotto pikachu pinsir poliwrath poochyena porygon2 " ++
%	  "porygonz registeel relicanth remoraid rufflet sableye scolipede scrafty seaking ",

	  "audino bagon baltoy banette bidoof braviary bronzor carracosta charmeleon " ++
	  "cresselia croagunk darmanitan deino emboar emolga exeggcute gabite " ++
	  "girafarig gulpin haxorus heatmor heatran ivysaur jellicent jumpluff kangaskhan " ++
	  "kricketune landorus ledyba loudred lumineon lunatone machamp magnezone mamoswine " ++
	  "nosepass petilil pidgeotto pikachu pinsir poliwrath poochyena porygon2 " ++
	  "porygonz registeel relicanth remoraid rufflet sableye scolipede scrafty seaking " ++
	  "sealeo silcoon simisear snivy snorlax spoink starly tirtouga trapinch treecko " ++
	  "tyrogue vigoroth vulpix wailord wartortle whismur wingull yamask",
	StringList = string:tokens(StringOfStrings, " "),
	grow_chains([ [X] || X <- StringList],StringList).
	
grow_chains(Pcs,All) ->
	%io:format("Pcs: ~p\n",[Pcs]),
	io:format("Still Alive\n"),
	%NextChainSet = lists:foldr(fun(Pc,Acc) -> Acc ++ find_links(Pc,All) end, [], Pcs),
	Res = [spawn(last_first_letter,find_links,[Pc,All,self()])|| Pc <- Pcs],
	%io:format("Res: ~p\n",[Res]),
	NextChainSet = receive_results(length(Pcs),[]),
	case NextChainSet of
	     [] -> hd(Pcs);
	     _ -> grow_chains(NextChainSet,All)
	end.
	
find_links(Pc,All,Pid) ->
	NotUsed = All -- Pc,
	Pid![Pc ++ [P] || P <- NotUsed, lists:last(lists:last(Pc)) =:= hd(P)].
	

receive_results(0,Acc) ->
	Acc;
receive_results(N,Acc) ->
	%io:format("Recibido: ~p\n",[N]),
	receive
		Result -> receive_results(N-1, Acc ++ Result)
	end.
