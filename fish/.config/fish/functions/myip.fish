function myip --description 'Get my public IP'
    dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '"'
end
