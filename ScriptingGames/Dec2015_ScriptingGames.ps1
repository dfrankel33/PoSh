$list = @"
1 Partridge in a pear tree
2 Turtle Doves
3 French Hens
4 Calling Birds
5 Golden Rings
6 Geese a laying
7 Swans a swimming
8 Maids a milking
9 Ladies dancing
10 Lords a leaping
11 Pipers piping
12 Drummers drumming
"@

write-output "FULL STRING LENGTH: $($list.Length)"


$nums = 1..12
$lines = $list.Split("`n")
$res1 = @()
$res2 = @()
foreach ($line in $lines) {
    #with num prefix
    $aobj = New-Object psobject
    $aobj | Add-Member -MemberType NoteProperty -Name 'Gift' -Value $line
    $aobj | Add-Member -MemberType NoteProperty -Name 'Length' -Value $line.Length
    $res1 += $aobj

    #without num prefix
    foreach ($num in $nums) {
        if ($line -like "$num *"){
            $linenoprefix = $line.Split("$num").Trim(" ")
            if ($linenoprefix.Length -eq 2) { $lineindex = 1 } elseif ($linenoprefix.Length -eq 3) { $lineindex = 2 }
            [int]$count = $line.Split(" ")[0]
            $bobj = New-Object psobject 
            $bobj | Add-Member -MemberType NoteProperty -Name 'Gift' -Value $linenoprefix[$lineindex]
            $bobj | Add-Member -MemberType NoteProperty -Name 'Num' -Value $count
            $bobj | Add-Member -MemberType NoteProperty -Name 'Length' -Value $linenoprefix[$lineindex].Length
            $res2 += $bobj
        }
    }
}

#results with num prefix, sorted by length:
#$res1.gift | sort length -Descending

#results without num prefix, sorted by length:
$res2 | sort length -Descending | ft num,gift -wrap

$birds = @('partridge','doves','hens','birds','geese','swans')

$birdcount = 0
foreach ($res in $res2) {
    foreach ($bird in $birds) {
        if ($res.gift -like "*$bird*") { 
            $birdcount += $res.num
        }
    }
}


Write-Output "BIRD COUNT: $birdcount"
Write-Output "TOTAL GIFTS: $(($res2.Num | measure-object -sum).sum)"

$n = 0
$x = 0
$res2.Num | 
    foreach { $n = 0..$_ 
        $n | foreach { $x += $_ }
    }
write-output "TOTAL CUMULATIVE GIFTS: $x"