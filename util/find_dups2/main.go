package main

import (
	"container/list"
	"crypto/sha1"
	"encoding/hex"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"time"
)

type FileInfo struct {
	Path  string
	Size  int64
	Mtime time.Time
}

var filesBySig = make(map[string]*list.List) // sig+size -> list of files
var filesBySize = make(map[int64]*list.List) // size -> list of files

func getSignature(path string) (string, error) {
	data, err := os.ReadFile(path)

	if err != nil {
		log.Print(err)
		return "", err
	}

	digest := sha1.Sum(data)
	return hex.EncodeToString(digest[:]), nil
}

func groupBySize(path string, info os.FileInfo, err error) error {
	if err != nil {
		log.Print(err)
		return nil
	}

	if info.IsDir() {
		return nil
	}

	if (info.Mode() & os.ModeSymlink) != 0 {
		return nil
	}

	size := info.Size()
	file_info := FileInfo{path, size, info.ModTime()}

	if lst, ok := filesBySize[size]; ok {
		lst.PushBack(file_info)
	} else {
		newList := list.New()
		newList.PushBack(file_info)
		filesBySize[size] = newList
	}

	return nil
}

func groupBySignature() {
	for _, listOfFiles := range filesBySize {
		if listOfFiles.Len() < 2 {
			continue
		}

		for e := listOfFiles.Front(); e != nil; e = e.Next() {
			if file_info, ok := e.Value.(FileInfo); ok {
				signature, err := getSignature(file_info.Path)

				if err != nil {
					log.Print(err)
					continue
				}

				key := fmt.Sprintf("%s/%d", signature, file_info.Size)

				if lst, ok := filesBySig[key]; ok {
					lst.PushBack(file_info)
				} else {
					newList := list.New()
					newList.PushBack(file_info)
					filesBySig[key] = newList
				}
			}
		}
	}
}

func readableSize(b int64) string {
	const unit = 1024
	if b < unit {
		return fmt.Sprintf("%d B", b)
	}
	div, exp := int64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %ciB",
		float64(b)/float64(div), "KMGTPE"[exp])
}

func showDuplicates() {

	// sort keys based on the file size

	keys := make([]string, 0, len(filesBySig))

	for key := range filesBySig {
		keys = append(keys, key)
	}

	sort.SliceStable(keys, func(i, j int) bool {
		size1 := filesBySig[keys[i]].Front().Value.(FileInfo).Size
		size2 := filesBySig[keys[j]].Front().Value.(FileInfo).Size
		return size1 > size2
	})

	for _, key := range keys {
		listOfFiles := filesBySig[key]

		if listOfFiles.Len() < 2 {
			continue
		}

		var separatorPrinted bool

		for e := listOfFiles.Front(); e != nil; e = e.Next() {
			if file_info, ok := e.Value.(FileInfo); ok {
				if !separatorPrinted {
					fmt.Printf("=== %s ============================================\n", readableSize(file_info.Size))
					separatorPrinted = true
				}

				fmt.Println(file_info.Path)
			}
		}
	}
}

func main() {
	log.SetFlags(log.Lshortfile)

	if len(os.Args) != 2 {
		log.Fatalf("Usage:  %s  <directory>", os.Args[0])
	}

	dir := os.Args[1]
	err := filepath.Walk(dir, groupBySize)

	if err != nil {
		log.Fatal(err)
	}

	groupBySignature()
	showDuplicates()
}
