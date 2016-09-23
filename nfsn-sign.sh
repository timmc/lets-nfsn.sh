#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo " + Performing initial run..."
dehydrated/dehydrated --cron

user_site=${MAIL##*/}
printf '
 + Done.

   Now add nfsn-cron.sh to your scheduled tasks so that the certificates
   will be renewed automatically.  To do that, go to

	https://members.nearlyfreespeech.net/%s/sites/%s/cron

   and use the following settings:

	Tag:                  dehydrated
	URL or Shell Command: %q
	User:                 me
	Hour:                 %d
	Day of Week:          Every
	Date:                 *

   The certificates will be renewed only when needed so it’s safe to
   schedule the task to run daily.

 + ATTN: /usr/local/bin/nfsn currently does not support being run from
         cron. A solution is being discussed; until one is available,
         this task will simply check the expiration date and error if it
         is within 30 days of expiry.
' \
	"${user_site%_*}" "$NFSN_SITE_NAME" \
	"$(realpath nfsn-cron.sh)" \
	"$(( $RANDOM % 24 ))"
