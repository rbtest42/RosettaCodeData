-- toBase :: Int -> Int -> String
on toBase(intBase, n)
    if (intBase < 36) and (intBase > 0) then
        inBaseDigits(items 1 thru intBase of "0123456789abcdefghijklmnopqrstuvwxyz", n)
    else
        "not defined for base " & (n as string)
    end if
end toBase


-- inBaseDigits :: String -> Int -> [String]
on inBaseDigits(strDigits, n)
    set intBase to length of strDigits

    script nextDigit
        on lambda(residue)
            set {divided, remainder} to quotRem(residue, intBase)

            {valid:divided > 0, value:(item (remainder + 1) of strDigits), new:divided}
        end lambda
    end script

    reverse of unfoldr(nextDigit, n) as string
end inBaseDigits



-- OTHER FUNCTIONS DERIVABLE FROM inBaseDigits

-- inUpperHex :: Int -> String
on inUpperHex(n)
    inBaseDigits("0123456789ABCDEF", n)
end inUpperHex

-- inDevanagariDecimal :: Int -> String
on inDevanagariDecimal(n)
    inBaseDigits("०१२३४५६७८९", n)
end inDevanagariDecimal

-- TEST
on run
    script
        on lambda(x)
            {{binary:toBase(2, x), octal:toBase(8, x), hex:toBase(16, x)}, ¬
                {upperHex:inUpperHex(x), dgDecimal:inDevanagariDecimal(x)}}
        end lambda
    end script

    map(result, [255, 240])
end run


-- GENERIC FUNCTIONS

-- unfoldr :: (b -> Maybe (a, b)) -> b -> [a]
on unfoldr(f, v)
    set mf to mReturn(f)
    set lst to {}
    set recM to mf's lambda(v)
    repeat while (valid of recM) is true
        set end of lst to value of recM
        set recM to mf's lambda(new of recM)
    end repeat
    lst & value of recM
end unfoldr

--  quotRem :: Integral a => a -> a -> (a, a)
on quotRem(m, n)
    {m div n, m mod n}
end quotRem

-- map :: (a -> b) -> [a] -> [b]
on map(f, xs)
    tell mReturn(f)
        set lng to length of xs
        set lst to {}
        repeat with i from 1 to lng
            set end of lst to lambda(item i of xs, i, xs)
        end repeat
        return lst
    end tell
end map

-- Lift 2nd class handler function into 1st class script wrapper
-- mReturn :: Handler -> Script
on mReturn(f)
    if class of f is script then
        f
    else
        script
            property lambda : f
        end script
    end if
end mReturn

-- until :: (a -> Bool) -> (a -> a) -> a -> a
on |until|(p, f, x)
    set mp to mReturn(p)
    set v to x

    tell mReturn(f)
        repeat until mp's lambda(v)
            set v to lambda(v)
        end repeat
    end tell
    return v
end |until|
