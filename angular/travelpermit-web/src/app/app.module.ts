import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppComponent } from './app.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { FormsModule } from '@angular/forms';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatTabsModule } from '@angular/material/tabs';
import { DialogReadQrCodeComponent } from './dialog-read-qr-code/dialog-read-qr-code.component';
import { MatDialogModule } from '@angular/material/dialog';
import { ReactiveFormsModule } from '@angular/forms';
import { NgxLoadingModule } from 'ngx-loading';
import { DialogAlertComponent } from './dialog-alert/dialog-alert.component';
import { HttpClientModule } from '@angular/common/http';
import { TravelPermitDisplayComponent } from './travel-permit-display/travel-permit-display.component';
import { MatExpansionModule } from '@angular/material/expansion';
import { TravelPermitTypePipe } from './pipes/travel-permit-type.pipe';
import { BioDocumentTypePipe } from './pipes/bio-document-type.pipe';
import { CpfPipe } from './pipes/cpf.pipe';
import { GenderPipe } from './pipes/gender.pipe';
import { GuardianshipPipe } from './pipes/guardianship.pipe';
import { DialogReadCodeComponent } from './dialog-read-code/dialog-read-code.component';
import { MatInputModule } from '@angular/material/input';
import { NgxMaskModule } from 'ngx-mask';
import { MatButtonModule } from '@angular/material/button';
import { SystemInfoComponent } from './system-version/system-info.component';
import { AppRoutingModule } from './app-routing.module';
import { HomeComponent } from './home/home.component';


@NgModule({
	declarations: [
		AppComponent,
		DialogReadQrCodeComponent,
		DialogAlertComponent,
		TravelPermitDisplayComponent,
		TravelPermitTypePipe,
		BioDocumentTypePipe,
		CpfPipe,
		GenderPipe,
		GuardianshipPipe,
		DialogReadCodeComponent,
		SystemInfoComponent,
		HomeComponent,
	],
	imports: [
		HttpClientModule,
		BrowserModule,
		BrowserAnimationsModule,
		FormsModule,
		MatToolbarModule,
		MatCardModule,
		MatIconModule,
		MatTabsModule,
		MatDialogModule,
		ReactiveFormsModule,
		MatExpansionModule,
		MatInputModule,
		MatButtonModule,
		NgxMaskModule.forRoot(),
		NgxLoadingModule.forRoot({}),
		AppRoutingModule
	],
	providers: [],
	bootstrap: [AppComponent]
})
export class AppModule { }
