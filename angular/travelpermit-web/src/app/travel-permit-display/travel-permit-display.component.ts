import { HttpClient } from '@angular/common/http';
import { Component, Input, OnInit } from '@angular/core';
import { Observable } from 'rxjs';
import { DestinationTypes, TravelPermitTypes } from 'src/api/enums';
import { TravelPermitModel, TravelPermitOfflineModel } from 'src/api/travel-permit';
import { environment } from 'src/environments/environment';

@Component({
	selector: 'app-travel-permit-display',
	templateUrl: './travel-permit-display.component.html',
	styleUrls: ['./travel-permit-display.component.scss']
})
export class TravelPermitDisplayComponent implements OnInit {
	@Input()
	travelPermit: TravelPermitModel | TravelPermitOfflineModel;
	readonly DestinationTypes = DestinationTypes;
	readonly TravelPermitTypes = TravelPermitTypes;
	
	loading: boolean = false;

	get isOnline(): boolean {
		return !this.travelPermit['version'];
	}

	constructor(
		private http: HttpClient,
	) { }

	ngOnInit() {
	}

	download() {
		this.loading = true;

		this.getDownloadTicket(this.travelPermit.key).subscribe(m => {
			document.location.href = environment.cnbEndpoint + m.location;
			this.loading = false;
		}, _ => this.loading = false);
	}

	getDownloadTicket(key: string): Observable<{location: string}> {
		return this.http.get<{location: string}>(`${environment.cnbEndpoint}/api/documents/keys/${key}/ticket?type=Signatures`);
	}
}
