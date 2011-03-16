How to install
==============

`$ sudo apt-get remove rubygems1.8`  
`$ wget http://mirror.linux.org.au/ubuntu//pool/universe/libg/libgems-ruby/rubygems1.8_1.3.7-2_all.deb`  
`$ sudo dpkg -i rubygems1.8_1.3.7-2_all.deb`  
`$ sudo apt-get install libopenssl-ruby git-core`  
`$ sudo gem install twitter addressable hashie multipart-post`  

`$ cd <<pasta>>`  
`$ git clone git://codaset.com/igorsantos07/twitrends.git twitrends`  

`$ sudo echo "/20 * * * *   root   ruby -rubygems -I <<pasta>>/twitrends/ <<pasta>>/tt.rb >>/var/log/twitrends.log 2>&1" >> /etc/crontab`  
