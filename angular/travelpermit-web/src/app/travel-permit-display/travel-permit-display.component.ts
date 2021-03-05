import { Component, Input, OnInit } from '@angular/core';
import { TravelPermitModel, TravelPermitOfflineModel } from 'src/api/travel-permit';

@Component({
	selector: 'app-travel-permit-display',
	templateUrl: './travel-permit-display.component.html',
	styleUrls: ['./travel-permit-display.component.scss']
})
export class TravelPermitDisplayComponent implements OnInit {

	@Input()
	travelPermit: TravelPermitModel

	@Input()
	offlineData: TravelPermitOfflineModel

	constructor(
	) { }

	ngOnInit() {
	}
}
