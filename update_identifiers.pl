#!/usr/bin/perl -w

use strict;
use HTML::Entities qw(decode_entities);
use HTML::TableExtract;
require HTTP::Request;
require HTTP::Cookies;
require LWP::UserAgent;

sub trim {
	@_ = $_ if not @_ and defined wantarray;
	@_ = @_ if defined wantarray;
	for (@_ ? @_ : $_) {
		if (defined $_) {
			s/\xC2\xA0//;
			s/\x96/-/g;
			s/^[“\s]+//;
			s/[-”\s]+$//;
			s/^\((.*)\)$/$1/;
			s/"/\\"/g;
		}
	}
	return wantarray ? @_ : $_[0] if defined wantarray;
}

sub fetch {
	my $type = shift;
	#my $req = HTTP::Request->new(GET => "http://www.dvb.org/products_registration/dvb_identifiers/identifiers.xml?type=" . $type);
	my $req = HTTP::Request->new(GET => "http://www.dvbservices.com/identifiers/" . $type . "?command=set_limit&data_per_page=100000");
	#my $req = HTTP::Request->new(GET => "file:" . $type . ".html");
	my $cookie_jar = HTTP::Cookies->new( 
		file => 'lwp_cookies.txt',
		autosave => 1,
	);
	my $ua = LWP::UserAgent->new(
		cookie_jar => $cookie_jar,
	);
	my $rsp = $ua->request($req);
	die $rsp->status_line unless ($rsp->is_success);
	return decode_entities($rsp->decoded_content);
}

sub parse_table {
	my $type = shift;
	my $page = fetch($type);
	my $te = HTML::TableExtract->new( headers => [ "ID / Range", @_ ] );
	$te->parse($page);
	# don't know the correct syntax to return the first element
	foreach my $ts ($te->tables) {
		return $ts;
	}
}

sub update {
	my $type = shift;
	my $t = parse_table(@_);
	open(OUT, ">src/strings/identifiers/" . $type . ".h");
	binmode(OUT, ":encoding(utf8)");
	foreach my $row ($t->rows) {
		my ($id, @fields) = trim @$row;
		$id =~ s/\s//g;
		if ($id =~ m/(0x[0-9a-fA-F]+)-(0x[0-9a-fA-F]+)/) {
			if (oct($2) < oct($1)) {
				print OUT "//";
			}
			print OUT "{ $1, $2, \"";
		} else {
			print OUT "{ $id, $id, \"";
		}
		for my $i (0 ... @fields - 1) {
			if (defined $fields[$i]) {
				print OUT $fields[$i];
				$i++;
				if (($i < @fields) and (defined $fields[$i])) {
					print OUT " | ";
				}
			} else {
				$i++;
			}
		}
		print OUT "\" },\n";
	}
	print OUT "{ 0, 0, NULL }\n";

	close(OUT);
}

sub bouquetID {
	update("bouquetID", "bouquet_id", "Bouquet_Name", "Country code", "Bouquet_Operator");
}

sub caSystemID {
	update("caSystemID", "ca_system_id", "CA_System_Specifier");
}

sub cpSystemID {
	update("cpSystemID", "cp_system_id", "CP_System_Specifier");
}

sub dataBroadcastID {
	update("dataBroadcastID", "data_broadcast_id", "Data_Broadcast_Specification_Name");
}

sub networkID {
	update("networkID", "network_id", "Network_Name", "Country code", "Network type", "Network_Operator");
}

sub originalNetworkID {
	update("originalNetworkID", "original_network_id", "Original_Network_Name", "Original_Network_Operator");
}

sub privateDataSpecifierID {
	update("privateDataSpecifierID", "private_data_spec_id", "Private_Data_Specifier_Organisation");
}

sub platformID {
	update("platformID", "platform_id", "Platform_Name", "Platform_Operator");
}

sub rootOfTrustID {
	update("rootOfTrustID", "root_of_trust_id", "Root_of_Trust_Description", "Root_of_Trust_Operator");
}

sub mhpOrganisationID {
	update("mhpOrganisationID", "mhp_organisation_id", "MHP_Organisation_Operator");
}

sub mhpApplicationTypeID {
	update("mhpApplicationTypeID", "mhp_app_type_id", "Application_Type_Description", "Application_Type_Operator");
}

sub mhpAITDescriptors {
	update("mhpAITDescriptors", "mhp_ait_descriptor", "AIT_Description", "AIT_Operator");
}

sub mhpProtocolID {
	update("mhpProtocolID", "mhp_protocol_id", "MHP_Protocol_Specifier");
}

# DVB-SI Identifiers
bouquetID();
caSystemID();
cpSystemID();
dataBroadcastID();
networkID();
originalNetworkID();
privateDataSpecifierID();
platformID();
rootOfTrustID();

# MHP Identifiers
mhpOrganisationID();
mhpApplicationTypeID();
mhpAITDescriptors();
mhpProtocolID();

