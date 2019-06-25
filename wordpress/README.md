README.md

The set of files in this folder is for creating a wordpress environment for non-production use.

Download or clone to your local, then run

<pre>
chmod +x wp-docker.sh
./wp-docker.sh
</pre>

`wp-docker.sh` creates a folder to work in.

At the end, processes are stopped and the folder is deleted.

1:45 into the <a target="_blank" href="https://app.pluralsight.com/player?course=using-docker-aws&author=david-clinton&name=440cc04e-14c6-45e5-ba8d-2df97c1b1358&clip=1&mode=live">video class</a>, the author notes that the wordpress-stack.yml contains passwords which, when in a production setting, would be substituted with variables managed by a secrets manager.



