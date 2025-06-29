file_line { 'Turn off passwd auth':
  path   => '/etc/ssh/ssh_config',
  line   => '    PasswordAuthentication no',
  match  => '^[#]*[\s]*(?i)PasswordAuthentication[\s]',
}

file_line { 'Declare identity file':
  path   => '/etc/ssh/ssh_config',
  line   => '    IdentityFile ~/.ssh/school',
  match  => '^[#]*[\s]*(?i)IdentityFile[\s]',
}