# Royalty Update Tool (Solana)

## About This Tool

When Yume Labs acquired Kitten Coup, one of the tasks we needed to do in order 
to complete the acquisition was to update the `creators` in the metadata for all 
2,216 NFTs. [Metaboss](https://metaboss.rs/) provides functionality to get the
existing NFT data, and to update the NFT data, but at the time ofwriting, there's 
no way to update the creators (recipients of royalties) across an entire 
collection.

Royalty Update Tool is a simple perl script to manage that step.

## Usage

I'm assuming you're using a system with a UNIX-compatible command line like Mac
OS X, Linux, Solaris, or most other things that aren't Windows. If not, you'll
need to work out how to do some of this stuff on your CLI.

You're also going to need perl (5, not Rakudo) installed, as well as cpanm (this
can be installed with `cpan App::Cpanminus` on most perl distributions), and
Metaboss (link above).

First, you'll need to decode the mint list for your NFT using metaboss:

```
metaboss --rpc YOUR_RPC_GOES_HERE decode mint --list-file YOUR_MINT_LIST_GOES_HERE -o input
```

So, if we're doing this for Kitten Coup using the SSC DAO public RPC:

```
metaboss --rpc https://ssc-dao.genesysgo.net decode mint --list-file kittencoup.json -o input
```

Now, pull the dependencies for the update tool:

```
cd /path/to/where/update/tool/lives
cpanm --installdeps .
```
Now, make a directory for the output files:

```
cd /path/to/your/decoded/files
mkdir output
```

Then, you'll use the Royalty Update Tool to update the creators for every NFT in 
the collection:

```
perl update.pl INPUT_FOLDER OUTPUT_FOLDER CREATORS_SEPARATED_BY_COLONS
```

The format for creators is as follows:

```
WALLET,SHARE,VERIFIED
```

Remember to keep your Candy Machine in the list. For Kitten Coup, the command
was the following (this uses two creators -- the verified candy machine and the
new unverified royalties address):

```
perl update.pl input output EDgWRRm2XtiGkddk4vVzFYvh5Vay9jMkvh8WbaqZDxiE,100,false:GkCN4jAHcCoBdNuHkmGygdmjasbceyMhzFsy82Hpdq8y,0,true
```

Finally, check the files to make sure they're right and update the NFTs with 
metaboss:

```
metaboss --rpc YOUR_RPC_GOES_HERE update data-all --keypair YOUR_SOLANA_WALLET_KEY --data-dir NEW_DATA_DIRECTORY
```

So for ours it was:

```
metaboss --rpc https://ssc-dao.genesysgo.net update data-all --keypair ~/.solana/id.json --data-dir output
```

We hope you find this tool useful. If you have any questions, feedback, or
suggestions, find us in [Yume Labs Discord](https://discord.gg/yume-labs).

## Warning

This was a quick script to solve a problem, it does not contain a lot of
validation logic or safeguards. If you put in a malformed SOL address, it's not
going to stop you.

You are responsible for checking the output files are correct before updating
your NFT metadata. If it does anything terrible, Yume Labs is not responsible.

## License

Copyright 2022 Yume Labs.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors 
may be used to endorse or promote products derived from this software without 
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
