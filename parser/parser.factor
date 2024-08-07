USING: arrays combinators kernel match math.parser multiline peg
peg.ebnf sequences strings vectors ;
IN: deckload.parser

TUPLE: var num ;
TUPLE: const name ;
TUPLE: rule name left right ;
TUPLE: import file ;

C: <var> var
C: <const> const
C: <rule> rule
C: <import> import 

MATCH-VARS: ?a _ ;

! : flatten ( tree -- flattened )
!     dup vector? [
!         {
!             { [ dup length 1 = ] [ ] }
!             { [ dup empty? ] [ ] }
!             [ unclip-last dup vector? [ append ] [ suffix ] if ]
!        } cond
!     ] when ;

! OLD
: flatten ( tree -- flattened )
    dup vector? [
        dup empty?
        [ unclip-last dup vector? [ append ] [ suffix ] if ] unless
        dup length 1 = [ first ] when
    ] when ;

! JohnB version
! : flatten* ( tree -- foo )
!     dup length 1 > [
!         unclip [ flatten* ] dip
!         over sequence? [ prefix ] [ swap 2array ] if 
!     ] [
!         ?first dup { [ sequence? ] [ length 1 = ] } 1&&
!         [ flatten* ] when
!     ] if ;

: parse-rule ( left right -- rule )
    swap dup vector?
    [ unclip-last ] [ V{ } swap ] if
    {
        { T{ const f ?a } [ ?a ] }
        [ "the last item on the left of a rule should be a const" throw ]
    } match-cond spin <rule> ;

EBNF: deckload-parse [=[
    spaces = [ \t\n\r]* => [[ drop ignore ]]
    import = "@"~ spaces [^=.[\]$@]+ spaces "."~ => [[ >string <import> ]]
    ident = [^=.[\]$@ \t\n\r]+ => [[ >string <const> ]]
    var = "$"~ [0-9]+ => [[ string>number <var> ]]
    expr = (spaces ( "["~ expr "]"~ | ident | var ) spaces)+ => [[ flatten ]]
    def = expr "="~ expr "."~ => [[ first2 parse-rule ]]
    prog = (def | import)*
]=]
