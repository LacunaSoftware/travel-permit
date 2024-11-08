import { Component, Input, OnInit } from '@angular/core';
import { JudiciaryTravelPermitModel, TravelPermitModel, TravelPermitOfflineModel } from 'src/api/travel-permit';
import { environment } from 'src/environments/environment';
import { DocumentService } from '../services/document.service';
import { DestinationTypes, TravelPermitTypes } from 'src/api/enums';

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

	@Input()
	judiciaryTravelPermit: JudiciaryTravelPermitModel;

	get canBeHostedOnEmergency() {
		return (this.travelPermit as TravelPermitModel)?.canBeHostedOnEmergency;
	}

	get authorizedByJudge() {
		return this.judiciaryTravelPermit?.authorizedByJudge || !!(this.travelPermit as TravelPermitOfflineModel)?.judge?.name;
	}

	get judgeName() {
		return this.judiciaryTravelPermit?.judge?.name || (this.travelPermit as TravelPermitOfflineModel)?.judge?.name;
	}

	get notaryName() {
		return this.judiciaryTravelPermit?.notary?.name || (this.travelPermit as TravelPermitOfflineModel)?.notary?.name;
	}

	loading = false;

	get isOnline(): boolean {
		return !this.travelPermit['version'];
	}

	constructor(
		private documentService: DocumentService,
	) { }

	ngOnInit() {
	}

	download() {
		this.loading = true;

		this.documentService.getDownloadTicket(this.travelPermit.key).subscribe(m => {
			document.location.href = environment.cnbEndpoint + m.location;
			this.loading = false;
		}, _ => this.loading = false);
	}
}
