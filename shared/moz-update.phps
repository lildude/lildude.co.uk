<?php
/**
 * Bringing automatic Thunderbird and Firefox updates to Solaris 10 and OpenSolaris.
 *
 * See http://lildude.co.uk/automatic-updates-thunderbird-firefox-solaris-opensolaris for more details.
 *
 * Copyright 2010 Colin Seymour
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *		http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

/**
 * Specify your mirror.
 *
 * I highly recommend you use a local mirror as it's likely to be quicker than
 * the primary mozilla.org servers.
 *
 * Ensure your path is as provided at http://www.mozilla.org/community/mirrors.html
 *
 * The default mirror here is that provided by the University of Kent in the UK
 * as this is my nearest (and quickest) mirror.
 */
$mirror = "http://www.mirrorservice.org/sites/releases.mozilla.org/pub/mozilla.org/";


/**
 * If you're using a beta version or an earlier version, change this to the
 * "latest-#.#" directory that corresponds to the version you want to use for
 * updates.
 *
 * For example, if you're using Thunderbird 3.1 beta, set $thunderbird to "latest-3.1"
 */
$thunderbird = "latest";
$firefox = "latest";



/**************** NO NEED TO MODIFY ANYTHING BELOW THIS POINT *****************/

// Arguments to nice vars
if ( $_GET['a'] && $_GET['v'] && $_GET['b'] ) {
	$app = strtolower( $_GET['a'] );
	$cur_VER = $_GET['v'];
	$build = $_GET['b'];
	list( $os, $rel, $arch ) = explode( '_', $build );
	$rel = ( $rel == '5.11' ) ? 'opensolaris' : 'solaris-10-fcs';
	$arch = ( strstr( $arch, 'x86' ) ) ? 'i386' : 'sparc';
	// We switch to FTP here as the directory listing comes without HTML formatting
	$url = str_replace( 'http://', 'ftp://', $mirror ) . "/$app/releases/".$$app."/contrib/solaris_tarball/";

	// Grab contents of $url
	$output = file_get_contents( $url );

	// Pull all the lines relevant to our version, OS and arch
	preg_match_all( "/^[-a-z0-9\s]+[\s]{4}([0-9]{2,})[\s0-9a-zA-Z:]+\s($app-($cur_VER\-)?[0-9\.\-abrc]{3,}\.en-US\.$rel-$arch\.(partial|complete).mar(\.md5sum)?)/mi", $output, $matches );

	// We use the HTTP download as it seems more reliable than using FTP.
	$url = str_replace( 'ftp://', 'http://', $url );
	if ( !empty( $matches[0] ) ) {
		if ( $matches[3][0] ) { // we have a partial
			$partial = $url . $matches[2][0];
			$psize = $matches[1][0];
			/* This is annoying: no partial hashes are provided so we need to do this
			 * ourselves, thankfully we can do this in one cmd and it shouldn't take too
			 * long as the partial is generally really small.
			 *
			 * This is the primary reason it's best to use a mirror that is near to
			 * you as your PHP may timeout.
			 */
			$phash = md5_file( $partial );

			$complete = $url . $matches[2][1];
			$csize = $matches[1][1];
			$chash = file_get_contents( $url . $matches[2][2] );
			$chash = explode(' ', $chash);
			$chash = $chash[0];
		} else {
			$complete = $url . $matches[2][1];
			$csize = $matches[1][1];
			$chash = file_get_contents( $url . $matches[2][2] );
			$chash = explode(' ', $chash);
			$chash = $chash[0];
		}

		preg_match( "/$app-([\.0-9ab]{2,}).+/", $matches[2][2], $matches1 );
		$new_VER = rtrim( $matches1[1], '.' );
		$update = '	<update type="minor" version="'.$new_VER.'" extensionVersion="'.$new_VER.'" buildID="20100403004202" detailsURL="http://www.mozilla.com/en-US/'.$app.'/'.$new_VER.'/releasenotes/"><patch type="complete" URL="'.$complete.'" hashFunction="MD5" hashValue="'.$chash.'" size="'.$csize.'"/>';
		if ( isset( $partial ) ) {
			$update .= '<patch type="partial" URL="'.$partial.'" hashFunction="MD5" hashValue="'.$phash.'" size="'.$psize.'"/>';
		}
		$update .= '</update>';
	} else {
		$update = '';
	}

	header( "Content-type: text/xml" );
	print '<?xml version="1.0"?><updates>';
	print $update;
 	print '</updates>';
} else {
	print "Something has gone wrong.";
}

?>
