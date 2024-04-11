import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { SystemInfoComponent } from './system-version/system-info.component';
import { HomeComponent } from './home/home.component';

const routes: Routes = [
	{ path: '', component: HomeComponent },
	{ path: 'system/info', component: SystemInfoComponent }
];

@NgModule({
	imports: [RouterModule.forRoot(routes)],
	exports: [RouterModule]
})
export class AppRoutingModule { }