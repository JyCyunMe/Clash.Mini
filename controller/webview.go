package controller

import (
	"fmt"
	"time"

	"github.com/Clash-Mini/Clash.Mini/constant"

	"github.com/Dreamacro/clash/log"
	"github.com/lxn/win"
	"github.com/skratchdot/open-golang/open"
	"github.com/zserge/lorca"
)

const (
	localUIPattern = `http://%s:%s/?hostname=%s&port=%s&secret=`
)

func Dashboard() {
	_, controllerPort := checkConfig()
	xScreen := int(win.GetSystemMetrics(win.SM_CXSCREEN))
	yScreen := int(win.GetSystemMetrics(win.SM_CYSCREEN))
	pageWidth := 800
	pageHeight := 580
	PageInit := lorca.Bounds{
		Left:        (xScreen - pageWidth) / 2,
		Top:         (yScreen - pageHeight) / 2,
		Width:       pageWidth,
		Height:      pageHeight,
		WindowState: "normal",
	}
	localUIUrl := fmt.Sprintf(localUIPattern, constant.Localhost, constant.DashboardPort,
		constant.Localhost, controllerPort)
	ui, err := lorca.New(localUIUrl, "", 0, 0)
	if err != nil {
		log.Errorln("create dashboard failed %v", err)
		err := open.Run(localUIUrl)
		if err != nil {
			log.Errorln("open dashboard failed %v", err)
			return
		}
	} else {
		defer func(ui lorca.UI) {
			err := ui.Close()
			if err != nil {
				log.Errorln("close dashboard failed %v", err)
			}
		}(ui)
		err := ui.SetBounds(PageInit)
		if err != nil {
			log.Errorln("SetBounds dashboard failed %v", err)
			return
		}
		// Wait until UI window is closed
		<-ui.Done()
		time.Sleep(2 * time.Second)
	}
}
