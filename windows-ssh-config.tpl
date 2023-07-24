add-content -path c:/users/r.boehme/.ssh/config -value @'

Host $(hostname)
    HostName $(hostname)
    User $(user)
    IdentityFile $(identityfile)   
'@